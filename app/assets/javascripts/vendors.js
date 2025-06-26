document.addEventListener('turbolinks:load', function() {
    console.log("PATH ==== app/assets/javascripts/vendors.js")
    
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
  
    // Handle Get Vendor Form
    const getVendorForm = document.getElementById('getVendorForm');
    if (getVendorForm) {
      getVendorForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const vendorId = document.getElementById('vendorId').value;
        const companyId = document.getElementById('getCompanyId').value;
        
        try {
          const response = await fetch(`/api/v1/vendors/${vendorId}?company_id=${companyId}`);
          const data = await response.json();
          document.getElementById('getResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('getResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle List Vendors Form
    const listVendorsForm = document.getElementById('listVendorsForm');
    if (listVendorsForm) {
      listVendorsForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const params = new URLSearchParams({
          company_id: document.getElementById('listCompanyId').value,
          name: document.getElementById('name').value,
          active: document.getElementById('active').value,
          maxresults: document.getElementById('maxResults').value,
          startposition: document.getElementById('startPosition').value
        });
  
        try {
          const response = await fetch(`/api/v1/vendors?${params}`);
          const data = await response.json();
          document.getElementById('listResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('listResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle Create Vendor Form
    const createVendorForm = document.getElementById('createVendorForm');
    if (createVendorForm) {
      createVendorForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const formData = new FormData(this);
  
        try {
          const response = await fetch('/api/v1/vendors', {
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
  