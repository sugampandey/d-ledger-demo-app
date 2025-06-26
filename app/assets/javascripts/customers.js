document.addEventListener('turbolinks:load', function() {
    console.log("PATH ==== app/assets/javascripts/customers.js")
    
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
  
    // Handle Get Customer Form
    const getCustomerForm = document.getElementById('getCustomerForm');
    if (getCustomerForm) {
      getCustomerForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const customerId = document.getElementById('customerId').value;
        const companyId = document.getElementById('getCompanyId').value;
        
        try {
          const response = await fetch(`/api/v1/customers/${customerId}?company_id=${companyId}`);
          const data = await response.json();
          document.getElementById('getResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('getResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle List Customers Form
    const listCustomersForm = document.getElementById('listCustomersForm');
    if (listCustomersForm) {
      listCustomersForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const params = new URLSearchParams({
          company_id: document.getElementById('listCompanyId').value,
          name: document.getElementById('name').value,
          active: document.getElementById('active').value,
          maxresults: document.getElementById('maxResults').value,
          startposition: document.getElementById('startPosition').value
        });
  
        try {
          const response = await fetch(`/api/v1/customers?${params}`);
          const data = await response.json();
          document.getElementById('listResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('listResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle Create Customer Form
    const createCustomerForm = document.getElementById('createCustomerForm');
    if (createCustomerForm) {
      createCustomerForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const formData = new FormData(this);
  
        try {
          const response = await fetch('/api/v1/customers', {
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
  