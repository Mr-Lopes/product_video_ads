function finalize() {
  
	var sheet = SpreadsheetApp.openByUrl(SPREADSHEET_URL).getSheetByName(SHEET_NAME)
  	
    var accountSelector = AdsManagerApp.accounts()
      .withLimit(ACCOUNTS_LIMIT)
  	  .get()
    
  	// Will run for 30 minutes then timeout
  	while (true) {
    
      // Find all account IDs
      var accountIds = Util.findAccountIds(sheet)

      // Start processing line matching account ID
      for (var row = 0; row < accountIds.length; row++) {

        var accountId = accountIds[row][0]

        if (accountId == '')
          break

        // + 2 because we need to skip header, and sheet rows start at 1 (instead of 0)
        processGenericRow(new Row(row + 2, sheet), accountId, accountSelector)
      }

      SpreadsheetApp.flush()

      Logger.log('Processed all account - Waiting %s seconds', SLEEP_TIME_SECONDS)
      Utilities.sleep(SLEEP_TIME_SECONDS * 1000)
  }
}

function processGenericRow(row, accountId, accountSelector) {
  
	// Find handler based on Status
    var status = row.get('Status')
    var handler = STATUS_HANDLERS[status]

    if (!handler)
      return
  
	// Switch to correct account
    while (accountSelector.hasNext()) {
  	
    var childAccount = accountSelector.next()
    
    if (childAccount.getCustomerId() == accountId)
    	AdsManagerApp.select(childAccount)
   }
    
   Logger.log('Handling %s to row %s', status, row.row)
   handler(row)

   // Persist to sheet
   row.save()
}