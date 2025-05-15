import { message, warn, fail, danger } from "danger"
const child_process = require('child_process');

var libFileChangeRegex = /.*lib.*/
var changelogChangeRegex = /.*CHANGELOG.md/

function checkIsChangelogUpdated() {
  const changedFiles = [...danger.git.created_files, ...danger.git.modified_files]
  const isChangelogUpdated = changedFiles.some((filePath) => changelogChangeRegex.test(filePath))
  const isLibFilesUpdated = changedFiles.some((filePath) => libFileChangeRegex.test(filePath))
  if (!isChangelogUpdated && isLibFilesUpdated) {
    warn('Please update the `CHANGELOG.md` file.')
  }
}

function checkIsDocumentationUpdated() {
  const changedFiles = [...danger.git.created_files, ...danger.git.modified_files]
  const isDocumentationUpdated = changedFiles.some((filePath) =>
    filePath.match(/docs\/.*/)
  )

  const isLibFilesUpdated = changedFiles.some((filePath) => libFileChangeRegex.test(filePath))

  if (!isDocumentationUpdated && isLibFilesUpdated) {
    warn('Please update the documentation in the `docs/` folder.')
  }
}

function checkIsBodyEmpty() {
  if (danger.github.pr.body == "") {
    warn("Please add a description to your PR.")
  }
}

function checkPRSize() {
  const maxLinesOfCode = 1000
  const linesOfCode = danger.github.pr.additions + danger.github.pr.deletions
  if (linesOfCode > maxLinesOfCode) {
    fail(`This pull request adds too many lines of code. It adds ${linesOfCode} lines, but the maximum allowed is ${maxLinesOfCode} lines.`)
  }
}

function runFlutterAnalyzer() {
  try {
    child_process.execSync('flutter analyze')
  } catch (error) {
    fail(`Flutter analyzer failed. Please fix the issues reported by the analyzer. ${error}`)
  }
}

checkIsChangelogUpdated()
checkIsDocumentationUpdated()
checkIsBodyEmpty()
checkPRSize()
runFlutterAnalyzer()