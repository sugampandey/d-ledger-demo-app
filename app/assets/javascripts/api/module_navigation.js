document.addEventListener('DOMContentLoaded', function() {
    // Handle main navigation active state
    console.log("PATH ==== app/assets/javascripts/api/module_navigation.js")
    const currentPath = window.location.pathname;
    console.log('currentPath', currentPath);
    document.querySelectorAll('.main-nav-item').forEach(item => {
      if (item.getAttribute('href') === currentPath) {
        item.classList.add('active');
      }
    });
  
    // Handle sidebar navigation
    function initializeSidebarNavigation() {
      document.querySelectorAll('.sidebar-item').forEach(item => {
        item.addEventListener('click', () => {
          document.querySelectorAll('.sidebar-item').forEach(i => i.classList.remove('active'));
          document.querySelectorAll('.api-section').forEach(section => section.classList.remove('active'));
          
          item.classList.add('active');
          const sectionId = item.getAttribute('data-section') + 'Section';
          const section = document.getElementById(sectionId);
          if (section) {
            section.classList.add('active');
          }
        });
      });
    }
  
    initializeSidebarNavigation();
  });
  