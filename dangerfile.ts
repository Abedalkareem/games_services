// Import the feedback functions
import { message, warn, fail, markdown } from "danger"

// Add a message to the table
message("You have added 2 more modules to the app")

//  Adds a warning to the table
warn("You have not included a CHANGELOG entry.")

// Declares a blocking 
fail(`ESLint has failed.`)