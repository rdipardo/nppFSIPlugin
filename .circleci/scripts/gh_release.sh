#!/usr/bin/bash
#
# Copyright (c) 2022 Robert Di Pardo, MIT License
#
# https://discuss.circleci.com/t/circle-branch-and-pipeline-git-branch-are-empty/44317/3
COMMIT=$(git rev-parse ${CIRCLE_TAG}) \
  && TMP=$(git branch -a --contains $COMMIT) \
  && BRANCH="${TMP##*/}"

cd "$BIN_DIR" || exit 0
printf '#### SHA256 Checksums\\n\\n' > sha256sums.md
printf '\\t%s\\n' "$(sha256sum ${SLUGX86})" >> sha256sums.md
printf '\\t%s\\n' "$(sha256sum ${SLUGX64})" >> sha256sums.md
curl -sL -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${GH_API_TOKEN}" \
        "https://api.github.com/repos/${CIRCLE_USERNAME}/${CIRCLE_PROJECT_REPONAME}/releases" \
    -d "{\"tag_name\":\"${CIRCLE_TAG}\",
        \"target_commitish\":\"${BRANCH}\",
        \"name\":\"${CIRCLE_TAG}\",
        \"body\":\"$(cat sha256sums.md)\",
        \"draft\":true,
        \"prerelease\":false,
        \"generate_release_notes\":false}"
