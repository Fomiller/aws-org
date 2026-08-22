locals {
  github_owner    = "Fomiller"
  github_owner_id = 36345389

  # Repos created, renamed or transferred after 2026-07-15 get the immutable
  # sub format, which folds the owner and repo IDs into the repo segment.
  # Accept both so a rename or an opt-in doesn't lock CI out.
  github_owner_segments = [
    local.github_owner,
    "${local.github_owner}@${local.github_owner_id}",
  ]
}
