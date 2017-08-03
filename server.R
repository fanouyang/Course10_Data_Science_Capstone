

suppressWarnings(library(tm))
suppressWarnings(library(stringr))
suppressWarnings(library(shiny))
suppressWarnings(library(gdata))


mesg <- as.character(NULL);

#-------------------------------------------------
# This function "Clean up" the user input string 
# before it is used to predict the next term
#-------------------------------------------------
CleanInputString <- function(inStr)
{
  
  # First remove the non-alphabatical characters
  inStr <- iconv(inStr, "latin1", "ASCII", sub=" ");
  inStr <- gsub("[^[:alpha:][:space:][:punct:]]", "", inStr);
  
  # Then convert to a Corpus
  inStrCrps <- VCorpus(VectorSource(inStr))
  
  # Convert the input sentence to lower case
  # Remove punctuations, numbers, white spaces
  # non alphabets characters
  inStrCrps <- tm_map(inStrCrps, content_transformer(tolower))
  inStrCrps <- tm_map(inStrCrps, removePunctuation)
  inStrCrps <- tm_map(inStrCrps, removeNumbers)
  inStrCrps <- tm_map(inStrCrps, stripWhitespace)
  inStr <- as.character(inStrCrps[[1]])
  inStr <- gsub("(^[[:space:]]+|[[:space:]]+$)", "", inStr)
  
  # Return the cleaned resulting senytense
  # If the resulting string is empty return empty and string.
  if (nchar(inStr) > 0) {
    return(inStr); 
  } else {
    return("");
  }
}
## read in n-gram (1-gram to 6-gram) datasets
# This data is already cleansed with N-Grams frequency in decending order
# The data was convert to lower case, punctuations removed, numbers removed, 
# white spaces removed, non print characters removed

freq1=read.csv("freq1.csv")
freq2=read.csv("freq2.csv")
freq3=read.csv("freq3.csv")
freq4=read.csv("freq4.csv")
freq5=read.csv("freq5.csv")
freq6=read.csv("freq6.csv")


#---------------------------------------
# Description of the Back Off Algorithm
#---------------------------------------
#apply a simple Katz's Back-off algorithm to predict the next word based on N-gram dataset; that is, depending on the phrase the user enters, we first predict the next word with hexa-gram data, if no hexa-gram is found, we back off to penta-gram, then to quad-gram, tri-gram, and bi-gram

PredNextTerm <- function(inStr)
{
  assign("mesg", "in PredNextTerm", envir = .GlobalEnv)
  
  # Clean up the input string and extract only the words with no leading and trailing white spaces
  inStr <- CleanInputString(inStr);
  
  # Split the input string across white spaces and then extract the length
  inStr <- unlist(strsplit(inStr, split=" "));
  inStrLen <- length(inStr);
  
  nxtTermFound <- FALSE;
  predNxtTerm <- as.character(NULL);
  #mesg <<- as.character(NULL);
  if (inStrLen >= 6 & !nxtTermFound)
  {
    # Assemble the terms of the input string separated by one white space each
    inStr1 <- paste(inStr[(inStrLen-4):inStrLen], collapse=" ");
    
    # Subset the six Gram data frame 
    searchStr <- paste("^",inStr1, sep = "");
    fDF6Temp <- freq6[grep (searchStr, freq6$word), ];
    
    # First test the six Gram using the four gram data frame
    # Check to see if any matching record returned
    if (length(fDF6Temp[, 1]) > 1 )
    {
      predNxtTerm <- fDF6Temp[1,1];
      nxtTermFound <- TRUE;
      mesg <<- "Next word is predicted using 6-gram."
    }
    fDF6Temp <- NULL;
  }
  
  # test the five Gram using the four gram data frame
  if (inStrLen >= 5 & !nxtTermFound)
  {
    # Assemble the terms of the input string separated by one white space each
    inStr1 <- paste(inStr[(inStrLen-3):inStrLen], collapse=" ");
    
    # Subset the five Gram data frame 
    searchStr <- paste("^",inStr1, sep = "");
    fDF5Temp <- freq5[grep (searchStr, freq5$word), ];
    
    # Check to see if any matching record returned
    if (length(fDF5Temp[, 1]) > 1 )
    {
      predNxtTerm <- fDF5Temp[1,1];
      nxtTermFound <- TRUE;
      mesg <<- "Next word is predicted using 5-gram."
    }
    fDF5Temp <- NULL;
  }
  
  
  
  if (inStrLen >= 4 & !nxtTermFound)
  {
    # Assemble the terms of the input string separated by one white space each
    inStr1 <- paste(inStr[(inStrLen-2):inStrLen], collapse=" ");
    
    # Subset the four Gram data frame 
    searchStr <- paste("^",inStr1, sep = "");
    fDF4Temp <- freq4[grep (searchStr, freq4$word), ];
    
    # Check to see if any matching record returned
    if (length(fDF4Temp[, 1]) > 1)
    {
      predNxtTerm <- fDF4Temp[1,1];
      nxtTermFound <- TRUE;
      mesg <<- "Next word is predicted using 4-gram."
    }
    fDF4Temp <- NULL;
  }
  
  #  test the Three Gram using the three gram data frame
  if (inStrLen >= 2 & !nxtTermFound)
  {
    # Assemble the terms of the input string separated by one white space each
    inStr1 <- paste(inStr[(inStrLen-1):inStrLen], collapse=" ");
    
    # Subset the three Gram data frame 
    searchStr <- paste("^",inStr1, sep = "");
    fDF3Temp <- freq3[grep (searchStr, freq3$word), ];
    
    # Check to see if any matching record returned
    if (length(fDF3Temp[, 1]) > 1)
    {
      predNxtTerm <- fDF3Temp[1,1];
      nxtTermFound <- TRUE;
      mesg <<- "Next word is predicted using 3-gram."
    }
    fDF3Temp <- NULL;
  }
  
  # test the Two Gram using the three gram data frame
  if (inStrLen >= 1 & !nxtTermFound)
  {
    # Assemble the terms of the input string separated by one white space each
    inStr1 <- inStr[inStrLen];
    
    # Subset the Two Gram data frame 
    searchStr <- paste("^",inStr1, sep = "");
    fDF2Temp <- freq2[grep (searchStr, freq2$word), ];
    
    # Check to see if any matching record returned
    if (length(fDF2Temp[, 1]) > 1)
    {
      predNxtTerm <- fDF2Temp[1,1];
      nxtTermFound <- TRUE;
      mesg <<- "Next word is predicted using 2-gram.";
    }
    fDF2Temp <- NULL;
  }
  
  #  If no next term found in Four, Three and Two Grams return the most
  #    frequently used term from the One Gram using the one gram data frame
  if (!nxtTermFound & inStrLen > 0)
  {
    predNxtTerm <- freq1$word[1];
    mesg <- "No next word found, the most frequent word is selected as next word."
  }
  
  nextTerm <- word(predNxtTerm, -1);
  
  if (inStrLen > 0){
    dfTemp1 <- data.frame(nextTerm, mesg);
    return(dfTemp1);
  } else {
    nextTerm <- "";
    mesg <-"";
    dfTemp1 <- data.frame(nextTerm, mesg);
    return(dfTemp1);
  }
}

msg <- ""
shinyServer(function(input, output) {
  output$prediction <- renderPrint({
    str2 <- CleanInputString(input$inputString);
    strDF <- PredNextTerm(str2);
    input$action;
    msg <<- as.character(strDF[1,2]);
    cat("", as.character(strDF[1,1]))
    cat("\n\t");
    cat("\n\t");
    cat("Note: ", as.character(strDF[1,2]));
  })
  
  output$text1 <- renderText({
    paste("Input Sentence: ", input$inputString)});
  
  output$text2 <- renderText({
    input$action;
    #paste("Note: ", msg);
  })
}
)