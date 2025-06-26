document.addEventListener('turbolinks:load', function() {
    console.log("PATH ==== app/assets/javascripts/companies.js")
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
  
    // Handle Get Company Form
    const getCompanyForm = document.getElementById('getCompanyForm');
    if (getCompanyForm) {
      getCompanyForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const companyId = document.getElementById('companyId').value;
        console.log('companyId', companyId)
        
        try {
          const response = await fetch(`/api/v1/companies/${companyId}`);
          const data = await response.json();
          document.getElementById('getResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('getResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle List Companies Form
    const listCompanyForm = document.getElementById('listCompanyForm');
    if (listCompanyForm) {
      listCompanyForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const params = new URLSearchParams({
          active: document.getElementById('active').value,
          maxresults: document.getElementById('maxResults').value,
          startposition: document.getElementById('startPosition').value
        });
  
        try {
          const response = await fetch(`/api/v1/companies?${params}`);
          const data = await response.json();
          document.getElementById('listResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('listResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle Create Company Form
    const createCompanyForm = document.getElementById('createCompanyForm');
    if (createCompanyForm) {
      createCompanyForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const companyData = {
            Name: document.getElementById('companyName').value
          };
  
        try {
          const response = await fetch('/api/v1/companies', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json'
            },
            body: JSON.stringify(companyData)
          });
          const data = await response.json();
          document.getElementById('createResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('createResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  });
  