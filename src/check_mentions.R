library(tidyverse)
library(gh)
library(lubridate)

#' Fetch GitHub issues where a user is mentioned
#'
#' Searches for issues in an organization that mention a specific username
#'
#' @param org_name GitHub organization name
#' @param username GitHub username to search for mentions (with or without @)
#' @param state Issue state filter: "open", "closed", or "all"
#' @return Data frame with issue details or empty data frame if none found
#' @export
get_issues_with_mentions <- function(org_name, username, state = "open") {
  # Remove @ if present
  username <- gsub("^@", "", username)
  
  # Validate state parameter
  if (!state %in% c("open", "closed", "all")) {
    stop("state must be one of: 'open', 'closed', or 'all'")
  }
  
  # Build query based on state parameter
  # Include mentions filter directly in the query for efficiency
  if (state == "all") {
    query <- sprintf("org:%s mentions:%s", org_name, username)
  } else {
    query <- sprintf("org:%s state:%s mentions:%s", org_name, state, username)
  }
  
  tryCatch({
    result <- gh("/search/issues",
                 q = query,
                 per_page = 100,
                 .limit = Inf)
    
    if (length(result$items) == 0) {
      return(data.frame())
    }
    
    # Convert to data frame
    # GitHub already filtered by mentions via the search query
    issues_df <- map_df(result$items, function(item) {
      tibble(
        number = item$number,
        title = item$title,
        repository = gsub("https://api.github.com/repos/", "", item$repository_url),
        state = item$state,
        url = item$html_url,
        createdAt = item$created_at,
        updatedAt = item$updated_at,
        closedAt = if (is.null(item$closed_at)) NA_character_ else item$closed_at,
        body = item$body %||% "",
        created_by = item$user$login %||% "",
        assignees = list(item$assignees),
        labels = list(item$labels)
      )
    })
    
    return(issues_df)
    
  }, error = function(e) {
    message("Error fetching issues: ", e$message)
    return(data.frame())
  })
}

#' Get repository commit count category
#'
#' Fast categorization of commits: returns "0", "1", or "2+"
#' Only fetches up to 2 commits (single API call)
#'
#' @param repo_name Repository in format "owner/repo"
#' @return Character string: "0", "1", "2+", or NA if error
#' @export
get_repo_commit_category <- function(repo_name) {
  # Fast categorization: 0, 1, or 2+
  # Only fetches up to 2 commits (1 API call)
  tryCatch({
    # Parse owner and repo
    owner <- strsplit(repo_name, "/")[[1]][1]
    repo <- strsplit(repo_name, "/")[[1]][2]
    
    # Fetch only 2 commits to categorize
    commits <- gh("/repos/{owner}/{repo}/commits",
                  owner = owner,
                  repo = repo,
                  per_page = 2,
                  .limit = 2)
    
    # Categorize
    count <- length(commits)
    if (count == 0) return("0")
    if (count == 1) return("1")
    return("2+")
    
  }, error = function(e) {
    # Return NA if we can't get commit info
    return(NA_character_)
  })
}

#' Get repository commit count
#'
#' Returns exact commit count or category depending on exact parameter
#'
#' @param repo_name Repository in format "owner/repo"
#' @param exact If TRUE, returns exact count (slow). If FALSE, returns category (fast)
#' @return Integer commit count if exact=TRUE, or character category if exact=FALSE
#' @export
get_repo_commit_count <- function(repo_name, exact = TRUE) {
  # If exact = FALSE, return category instead
  if (!exact) {
    return(get_repo_commit_category(repo_name))
  }
  
  # Exact count (slow - fetches up to 1000 commits)
  tryCatch({
    # Parse owner and repo
    owner <- strsplit(repo_name, "/")[[1]][1]
    repo <- strsplit(repo_name, "/")[[1]][2]
    
    # Get repository info which includes default branch
    repo_info <- gh("/repos/{owner}/{repo}",
                    owner = owner,
                    repo = repo)
    
    # Get commits count from the default branch
    commits <- gh("/repos/{owner}/{repo}/commits",
                  owner = owner,
                  repo = repo,
                  sha = repo_info$default_branch,
                  per_page = 1)
    
    # GitHub returns Link header with total count
    # We'll use a simple approach: count all commits up to a limit
    all_commits <- gh("/repos/{owner}/{repo}/commits",
                      owner = owner,
                      repo = repo,
                      sha = repo_info$default_branch,
                      per_page = 100,
                      .limit = 1000)  # Reasonable limit
    
    return(length(all_commits))
    
  }, error = function(e) {
    # Return NA if we can't get commit count
    return(NA)
  })
}

#' Get detailed information for a specific issue
#'
#' Fetches issue details including all comments
#'
#' @param repo_name Repository in format "owner/repo"
#' @param issue_number Issue number to fetch
#' @return List with issue details and comments, or empty list on error
#' @export
get_issue_details <- function(repo_name, issue_number) {
  tryCatch({
    # Get issue details
    issue <- gh("/repos/{owner}/{repo}/issues/{issue_number}",
                owner = strsplit(repo_name, "/")[[1]][1],
                repo = strsplit(repo_name, "/")[[1]][2],
                issue_number = issue_number)
    
    # Get comments
    comments <- gh("/repos/{owner}/{repo}/issues/{issue_number}/comments",
                   owner = strsplit(repo_name, "/")[[1]][1],
                   repo = strsplit(repo_name, "/")[[1]][2],
                   issue_number = issue_number,
                   per_page = 100,
                   .limit = Inf)
    
    list(
      number = issue$number,
      title = issue$title,
      state = issue$state,
      url = issue$html_url,
      createdAt = issue$created_at,
      updatedAt = issue$updated_at,
      body = issue$body,
      assignees = issue$assignees,
      labels = issue$labels,
      author = list(login = issue$user$login),
      comments = if (length(comments) > 0) {
        map(comments, function(c) {
          list(
            body = c$body,
            author = list(login = c$user$login),
            created_at = c$created_at
          )
        })
      } else {
        list()
      }
    )
    
  }, error = function(e) {
    message("Error fetching issue details: ", e$message)
    list()
  })
}

#' Get mention message and comment count for an issue
#'
#' Finds the most recent comment containing a mention of the specified user
#'
#' @param repo_name Repository in format "owner/repo"
#' @param issue_number Issue number to check
#' @param issue_body Original issue body text
#' @param username Username to search for mentions (with or without @)
#' @return List with num_comments and mention_message
#' @export
get_mention_and_comment_info <- function(repo_name, issue_number, issue_body, username) {
  detailed_issue <- get_issue_details(repo_name, issue_number)
  comments <- detailed_issue$comments
  
  # Create mention pattern based on username
  username <- gsub("^@", "", username)  # Remove @ if present
  mention_pattern <- sprintf("@%s\\b", username)
  
  # Check if the initial issue body contains a mention
  mention_message <- ""
  if (grepl(mention_pattern, issue_body %||% "")) {
    mention_message <- issue_body %||% ""
  }
  
  if (is.null(comments) || length(comments) == 0) {
    return(list(
      num_comments = 0,
      mention_message = mention_message
    ))
  }
  
  # Find the most recent mention message
  last_mention_message <- mention_message
  
  for (i in rev(seq_along(comments))) {
    comment <- comments[[i]]
    comment_body <- comment$body %||% ""
    
    if (grepl(mention_pattern, comment_body)) {
      last_mention_message <- comment_body
      break
    }
  }
  
  list(
    num_comments = length(comments),
    mention_message = last_mention_message
  )
}

#' Prepare response data from issues
#'
#' Processes issues dataframe and optionally fetches detailed information
#'
#' @param issues Data frame of issues from get_issues_with_mentions
#' @param username Username for mention detection
#' @param fetch_details If TRUE, fetches detailed issue info (slower)
#' @param exact_commit_count If TRUE, gets exact commit count (slower)
#' @return Data frame with issue details and response columns
#' @export
prepare_response_data <- function(issues, username, fetch_details = FALSE, exact_commit_count = FALSE) {
  if (nrow(issues) == 0) {
    return(data.frame())
  }
  
  # Process each issue individually
  response_list <- list()
  for (i in seq_len(nrow(issues))) {
    issue <- issues[i, ]
    repo_name <- issue$repository %||% ""
    
    # Only fetch detailed info if requested
    if (fetch_details) {
      if (repo_name != "" && !is.na(issue$number)) {
        mention_info <- get_mention_and_comment_info(repo_name, issue$number, issue$body, username)
      } else {
        mention_info <- list(num_comments = 0, mention_message = issue$body %||% "")
      }
      
      # Get commit count (category by default, exact if requested)
      commit_count <- get_repo_commit_count(repo_name, exact = exact_commit_count)
    } else {
      # Skip expensive API calls for analysis mode
      mention_info <- list(num_comments = NA_integer_, mention_message = NA_character_)
      commit_count <- NA_character_
    }
    
    response_list[[i]] <- tibble(
      repository = repo_name,
      issue_number = issue$number,
      issue_title = issue$title,
      issue_url = issue$url,
      issue_state = issue$state,
      created_by = issue$created_by,
      created_at = issue$createdAt,
      updated_at = issue$updatedAt,
      closed_at = issue$closedAt,
      issue_body = issue$body,
      mention_message = mention_info$mention_message,
      num_comments = mention_info$num_comments,
      num_commits = commit_count,
      prepared_response = ""
    )
  }
  
  response_data <- bind_rows(response_list) |>
    mutate(
      issue_body = substr(gsub("\n", " ", issue_body), 1, 200),
      mention_message = substr(gsub("\n", " ", mention_message), 1, 500),
      post_response = "No",
      close_issue = "No"  # Default to No, user can change to Yes for completed assignments
    )
  
  response_data
}

#' Check for mentions in GitHub issues
#'
#' Main function to fetch and process issues where a user is mentioned
#'
#' @param org_name GitHub organization name
#' @param username GitHub username to search for mentions
#' @param state Issue state filter: "open", "closed", or "all"
#' @param fetch_details If TRUE, fetches detailed issue info (slower)
#' @param exact_commit_count If TRUE, gets exact commit count (slower)
#' @param verbose If TRUE, prints progress messages
#' @return Data frame with processed issue data ready for responses
#' @export
check_mentions <- function(org_name, username, state = "open",
                           fetch_details = TRUE, exact_commit_count = FALSE,
                           verbose = TRUE) {
  if (verbose) cat(sprintf("🔍 Checking issues in organization: %s\n", org_name))
  
  issues <- get_issues_with_mentions(org_name, username, state)
  
  if (nrow(issues) == 0) {
    if (verbose) cat("No issues found where you're mentioned\n")
    return(data.frame())
  }
  
  if (verbose) {
    cat(sprintf("📋 Found %d issues with mentions\n", nrow(issues)))
    if (fetch_details) {
      cat("Processing issue details...\n")
    } else {
      cat("Skipping detailed info (fast mode)...\n")
    }
  }
  
  response_data <- prepare_response_data(issues, username,
                                         fetch_details = fetch_details,
                                         exact_commit_count = exact_commit_count)
  
  if (verbose) {
    cat("\n📊 Summary:\n")
    cat(sprintf("  - Total issues with mentions: %d\n", nrow(response_data)))
    cat("\n💡 Next steps:\n")
    cat("  1. Review issues and decide which need responses\n")
    cat("  2. Set 'post_response' to 'Yes' for responses you want to post\n")
    cat("  3. Use post_responses() function to post the responses\n")
  }
  
  return(response_data)
}

#' Null coalescing operator
#'
#' Returns y if x is NULL, empty, or empty string
#'
#' @param x Value to check
#' @param y Default value to return if x is null/empty
#' @return x if not null/empty, otherwise y
`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0 || (is.character(x) && x == "")) y else x
}
