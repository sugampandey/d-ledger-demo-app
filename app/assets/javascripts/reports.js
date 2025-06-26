document.addEventListener('turbolinks:load', function() {
    console.log("PATH ==== app/assets/javascripts/reports.js")
    console.log("Reports.js initialized")
    
    // Handle sidebar navigation
    const sidebarItems = document.querySelectorAll('.sidebar-item');
    const apiSections = document.querySelectorAll('.api-section');
    
    console.log(`Found ${sidebarItems.length} sidebar items and ${apiSections.length} API sections`)
  
    sidebarItems.forEach(item => {
      item.addEventListener('click', function() {
        const sectionId = this.getAttribute('data-section');
        console.log(`Sidebar item clicked: ${sectionId}`)
        
        // Remove active class from all items and sections
        sidebarItems.forEach(i => i.classList.remove('active'));
        apiSections.forEach(s => s.classList.remove('active'));
  
        // Add active class to clicked item and corresponding section
        this.classList.add('active');
        const fullSectionId = sectionId + 'Section';
        const targetSection = document.getElementById(fullSectionId);
        if (targetSection) {
          targetSection.classList.add('active');
          console.log(`Activated section: ${fullSectionId}`)
        } else {
          console.warn(`Section not found: ${fullSectionId}`)
        }
      });
    });
  
    // Handle Get Balance Sheet Form
    const getBalanceSheetForm = document.getElementById('getBalanceSheetForm');
    if (getBalanceSheetForm) {
      console.log("Balance Sheet form found")
      getBalanceSheetForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        console.log("Balance Sheet form submitted")
        
        const params = new URLSearchParams();
        params.append('company_id', document.getElementById('bsCompanyId').value);
        
        // Optional parameters
        const startDate = document.getElementById('bsStartDate').value;
        if (startDate) params.append('start_date', startDate);
        
        const endDate = document.getElementById('bsEndDate').value;
        if (endDate) params.append('end_date', endDate);
        
        const partnerId = document.getElementById('bsPartnerId').value;
        if (partnerId) params.append('partner_id', partnerId);
        
        const accountId = document.getElementById('bsAccountId').value;
        if (accountId) params.append('account_id', accountId);
        
        const analyticClassId = document.getElementById('bsAnalyticClassId').value;
        if (analyticClassId) params.append('analytic_class_id', analyticClassId);
        
        console.log(`Balance Sheet API request params: ${params.toString()}`)
        
        try {
          const url = `/api/v1/reports/balance_sheet?${params}`;
          console.log(`Fetching Balance Sheet data from: ${url}`)
          const response = await fetch(url);
          const data = await response.json();
          console.log("Balance Sheet API response received", data)
          document.getElementById('balanceSheetResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          console.error("Balance Sheet API error:", error)
          document.getElementById('balanceSheetResult').innerHTML = 'Error: ' + error.message;
        }
      });
    } else {
      console.log("Balance Sheet form not found in the DOM")
    }

    const getProfitLossForm = document.getElementById('getProfitLossForm');
    if (getProfitLossForm) {
      console.log("Profit Loss form found")
      getProfitLossForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        console.log("Profit Loss form submitted")

        const params = new URLSearchParams();
        params.append('company_id', document.getElementById('plCompanyId').value);

        // Optional parameters
        const startDate = document.getElementById('plStartDate').value;
        if (startDate) params.append('start_date', startDate);

        const endDate = document.getElementById('plEndDate').value;
        if (endDate) params.append('end_date', endDate);

        console.log(`Profit Loss API request params: ${params.toString()}`)

        try {
          const url = `/api/v1/reports/profit_loss?${params}`;
          console.log(`Fetching Profit Loss data from: ${url}`)
          const response = await fetch(url);
          const data = await response.json();
          console.log("Profit Loss API response received", data)
          document.getElementById('profitLossResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          console.error("Profit Loss API error:", error)
          document.getElementById('profitLossResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle Get General Ledger Form
    const getGeneralLedgerForm = document.getElementById('getGeneralLedgerForm');
    if (getGeneralLedgerForm) {
      console.log("General Ledger form found")
      getGeneralLedgerForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        console.log("General Ledger form submitted")
        
        const params = new URLSearchParams();
        params.append('company_id', document.getElementById('glCompanyId').value);
        
        // Optional parameters
        const startDate = document.getElementById('glStartDate').value;
        if (startDate) params.append('start_date', startDate);
        
        const endDate = document.getElementById('glEndDate').value;
        if (endDate) params.append('end_date', endDate);
        
        const partnerId = document.getElementById('glPartnerId').value;
        if (partnerId) params.append('partner_id', partnerId);
        
        const accountId = document.getElementById('glAccountId').value;
        if (accountId) params.append('account_id', accountId);
        
        const analyticClassId = document.getElementById('glAnalyticClassId').value;
        if (analyticClassId) params.append('analytic_class_id', analyticClassId);
        
        const columns = document.getElementById('glColumns').value;
        if (columns) params.append('columns', columns);
        
        const sortBy = document.getElementById('glSortBy').value;
        if (sortBy) params.append('sort_by', sortBy);
        
        const sortOrder = document.getElementById('glSortOrder').value;
        if (sortOrder) params.append('sort_order', sortOrder);
        
        console.log(`General Ledger API request params: ${params.toString()}`)
        
        try {
          const url = `/api/v1/reports/general_ledger?${params}`;
          console.log(`Fetching General Ledger data from: ${url}`)
          const response = await fetch(url);
          const data = await response.json();
          console.log("General Ledger API response received", data)
          document.getElementById('generalLedgerResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          console.error("General Ledger API error:", error)
          document.getElementById('generalLedgerResult').innerHTML = 'Error: ' + error.message;
        }
      });
    } else {
      console.log("General Ledger form not found in the DOM")
    }
});
