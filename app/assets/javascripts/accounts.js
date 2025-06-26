
document.addEventListener('turbolinks:load', function() {
    console.log("PATH ==== app/assets/javascripts/accounts.js")
    // Handle sidebar navigation
    const sidebarItems = document.querySelectorAll('.sidebar-item');
    const apiSections = document.querySelectorAll('.api-section');
  
    sidebarItems.forEach(item => {
      item.addEventListener('click', function() {
        // Remove active class from all items and sections
        sidebarItems.forEach(i => i.classList.remove('active'));
        apiSections.forEach(s => s.classList.remove('active'));
  
        // Add active class to clicked item and corresponding section
        this.classList.add('active');
        const sectionId = this.getAttribute('data-section') + 'Section';
        document.getElementById(sectionId).classList.add('active');
      });
    });
  
    // Handle Get Account Form
    const getAccountForm = document.getElementById('getAccountForm');
    if (getAccountForm) {
      getAccountForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const accountId = document.getElementById('accountId').value;
        const companyId = document.getElementById('getCompanyId').value;
        console.log('Account ID:', accountId);
        console.log('Company ID:', companyId);
        
        try {
            console.log(`/api/v1/accounts/${accountId}?company_id=${companyId}`)
          const response = await fetch(`/api/v1/accounts/${accountId}?company_id=${companyId}`);
          const data = await response.json();
          document.getElementById('getResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('getResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle List Accounts Form
    const listAccountsForm = document.getElementById('listAccountsForm');
    if (listAccountsForm) {
      listAccountsForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const params = new URLSearchParams({
          company_id: document.getElementById('listCompanyId').value,
          name: document.getElementById('name').value,
          account_type: document.getElementById('accountType').value,
          active: document.getElementById('active').value,
          maxresults: document.getElementById('maxResults').value,
          startposition: document.getElementById('startPosition').value
        });
  
        try {
          const response = await fetch(`/api/v1/accounts?${params}`);
          const data = await response.json();
          document.getElementById('listResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('listResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle Create Account Form
    const createAccountForm = document.getElementById('createAccountForm');
    if (createAccountForm) {
      createAccountForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const formData = new FormData(this);
  
        try {
          const response = await fetch('/api/v1/accounts', {
            method: 'POST',
            body: formData
          });
          const data = await response.json();
          document.getElementById('createResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('createResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  });
  