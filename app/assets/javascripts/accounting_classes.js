document.addEventListener('turbolinks:load', function() {
    console.log("PATH ==== app/assets/javascripts/accounting_classes.js")
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
  
    // Handle Get Accounting Class Form
    const getAccountingClassForm = document.getElementById('getAccountingClassForm');
    if (getAccountingClassForm) {
      getAccountingClassForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const accountingClassId = document.getElementById('accountingClassId').value;
        const companyId = document.getElementById('getCompanyId').value;
        
        try {
          const response = await fetch(`/api/v1/accounting_classes/${accountingClassId}?company_id=${companyId}`);
          const data = await response.json();
          document.getElementById('getResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('getResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle List Accounting Classes Form
    const listAccountingClassForm = document.getElementById('listAccountingClassForm');
    if (listAccountingClassForm) {
      listAccountingClassForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const params = new URLSearchParams({
          company_id: document.getElementById('listCompanyId').value,
          active: document.getElementById('active').value,
          maxresults: document.getElementById('maxResults').value,
          startposition: document.getElementById('startPosition').value
        });
  
        try {
          const response = await fetch(`/api/v1/accounting_classes?${params}`);
          const data = await response.json();
          document.getElementById('listResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('listResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle Create Accounting Class Form
    const createAccountingClassForm = document.getElementById('createAccountingClassForm');
    if (createAccountingClassForm) {
      createAccountingClassForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const accountingClassData = {
          name: document.getElementById('accountingClassName').value,
          company_id : document.getElementById('createCompanyId').value
        };
  
        try {
          const response = await fetch(`/api/v1/accounting_classes`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify(accountingClassData)
          });
          const data = await response.json();
          document.getElementById('createResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('createResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  });
  