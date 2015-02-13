in_travis <- function() {
  return (Sys.getenv("TRAVIS_REPO_SLUG") > 0)
}

get_travis_build_info <- function() {
  slug <- Sys.getenv("TRAVIS_REPO_SLUG") %||% NULL
  
  if (is.null(slug)) {
    return(NULL)
  }
  
  slug_info <- strsplit(slug, "/")[[1]]

  list(
    user = slug_info[1],
    repo = slug_info[2],
    pull = Sys.getenv("TRAVIS_PULL_REQUEST") %||% NULL,
    branch = Sys.getenv("TRAVIS_BRANCH") %||% NULL,
    commit = Sys.getenv("TRAVIS_COMMIT") %||% NULL
  )
}

github_comment <- function(text, token = settings$comment_token) {

  info <- get_travis_build_info()

  if (!is.null(info$pull) && info$pull != "false") {
    response <- httr::POST("https://api.github.com",
      path=paste(sep = "/", "repos", info$user, info$repo, "issues", info$pull, "comments"),
      body = list("body"=jsonlite::unbox(text)),
      query = list(access_token = token),
      encode = "json")
    httr::stop_for_status(response)
  } else if (!is.null(info$commit)) {
    response <- httr::POST("https://api.github.com",
      path=paste(sep = "/", "repos", info$user, info$repo, "commits", info$commit, "comments"),
      body = list("body"=jsonlite::unbox(text)),
      query = list(access_token = token),
      encode = "json")
    httr::stop_for_status(response)
  }
}