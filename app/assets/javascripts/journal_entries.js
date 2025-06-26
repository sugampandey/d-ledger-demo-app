document.addEventListener('turbolinks:load', function() {
    console.log("PATH ==== app/assets/javascripts/journal_entries.js")
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
  
    // Handle Get Journal Entry Form
    const getJournalEntryForm = document.getElementById('getJournalEntryForm');
    if (getJournalEntryForm) {
      getJournalEntryForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const journalEntryId = document.getElementById('journalEntryId').value;
        const companyId = document.getElementById('getCompanyId').value;
        
        try {
          const response = await fetch(`/api/v1/journal_entries/${journalEntryId}?company_id=${companyId}`);
          const data = await response.json();
          document.getElementById('getResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('getResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle List Journal Entries Form
    const listJournalEntryForm = document.getElementById('listJournalEntryForm');
    if (listJournalEntryForm) {
      listJournalEntryForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        const params = new URLSearchParams();
        
        params.append('company_id', document.getElementById('listCompanyId').value);
        
        // Only add parameters if they have values
        const journalId = document.getElementById('listJournalId').value;
        if (journalId) params.append('journal_id', journalId);
        
        const dateFrom = document.getElementById('dateFrom').value;
        if (dateFrom) params.append('date_from', dateFrom);
        
        const dateTo = document.getElementById('dateTo').value;
        if (dateTo) params.append('date_to', dateTo);
        
        params.append('max_results', document.getElementById('maxResults').value);
        params.append('start_position', document.getElementById('startPosition').value);
  
        try {
          const response = await fetch(`/api/v1/journal_entries?${params}`);
          const data = await response.json();
          document.getElementById('listResult').innerHTML = JSON.stringify(data, null, 2);
        } catch (error) {
          document.getElementById('listResult').innerHTML = 'Error: ' + error.message;
        }
      });
    }
  
    // Handle Create Journal Entry Form
    const createJournalEntryForm = document.getElementById('createJournalEntryForm');
    if (createJournalEntryForm) {
      // Add journal line functionality
      const addJournalLineBtn = document.getElementById('addJournalLine');
      const journalLinesContainer = document.getElementById('journalLines');
      
      if (addJournalLineBtn) {
        addJournalLineBtn.addEventListener('click', function() {
          const newLineBox = document.createElement('div');
          newLineBox.className = 'journal-line-box';
          
          const newLine = document.createElement('div');
          newLine.className = 'journal-line';
          newLine.innerHTML = `
            <div class="form-group">
              <label>Amount:</label>
              <input type="number" class="line-amount" step="0.01" required>
            </div>
            <div class="form-group">
              <label>Description:</label>
              <input type="text" class="line-description">
            </div>
            <div class="form-group">
              <label>Posting Type:</label>
              <select class="line-posting-type" required>
                <option value="Debit">Debit</option>
                <option value="Credit">Credit</option>
              </select>
            </div>
            <div class="form-group">
              <label>Account ID:</label>
              <input type="number" class="line-account-id" required>
            </div>
            <div class="form-group">
              <label>Partner ID:</label>
              <input type="number" class="line-partner-id">
            </div>
            <div class="form-group">
              <label>Class ID:</label>
              <input type="number" class="line-class-id">
            </div>
            <button type="button" class="remove-line">Remove</button>
          `;
          
          newLineBox.appendChild(newLine);
          journalLinesContainer.appendChild(newLineBox);
          
          // Add event listener to the new remove button
          newLine.querySelector('.remove-line').addEventListener('click', function() {
            journalLinesContainer.removeChild(newLineBox);
          });
        });
      }
      
      // Add event listener for existing remove buttons
      document.querySelectorAll('.remove-line').forEach(button => {
        button.addEventListener('click', function() {
          const lineBox = this.closest('.journal-line-box');
          lineBox.parentElement.removeChild(lineBox);
        });
      });
  
      createJournalEntryForm.addEventListener('submit', async function(e) {
        e.preventDefault();
        console.log("createJournalEntryForm")
        
        // Collect all journal lines
        const journalLines = [];
        document.querySelectorAll('.journal-line').forEach(line => {
            journalLines.push({
            amount: line.querySelector('.line-amount').value,
            description: line.querySelector('.line-description').value,
            posting_type: line.querySelector('.line-posting-type').value,
            account_id: line.querySelector('.line-account-id').value,
            partner_id: line.querySelector('.line-partner-id').value || null,
            class_id: line.querySelector('.line-class-id').value || null
            });
        });
        
        const journalEntryData = {
            company_id: document.getElementById('createCompanyId').value,
            description: document.getElementById('journalDescription').value,
            txn_date: document.getElementById('TxnDate').value,
            journal_lines: journalLines
        };

        try {
            console.log("Journal Entry Data:", journalEntryData);
            const response = await fetch(`/api/v1/journal_entries`, {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json'
              },
              body: JSON.stringify(journalEntryData)
            });
            const data = await response.json();
            document.getElementById('createResult').innerHTML = JSON.stringify(data, null, 2);
          } catch (error) {
            document.getElementById('createResult').innerHTML = 'Error: ' + error.message;
          }
      });
    }
  });
  