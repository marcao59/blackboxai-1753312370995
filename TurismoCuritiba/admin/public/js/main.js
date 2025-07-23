// Main JavaScript file for Turismo Curitiba Admin Panel

// Global variables
let currentPage = 1;
let currentLimit = 10;
let currentFilters = {};

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
});

// Initialize application
function initializeApp() {
    initializeSidebar();
    initializeUserMenu();
    initializeImageUpload();
    initializeForms();
    initializeDataTables();
    initializeModals();
    loadDashboardStats();
}

// Sidebar functionality
function initializeSidebar() {
    const sidebarToggle = document.querySelector('.sidebar-toggle');
    const sidebar = document.querySelector('.sidebar');
    
    if (sidebarToggle && sidebar) {
        sidebarToggle.addEventListener('click', function() {
            sidebar.classList.toggle('show');
        });
    }
    
    // Close sidebar when clicking outside on mobile
    document.addEventListener('click', function(e) {
        if (window.innerWidth <= 768) {
            if (!sidebar.contains(e.target) && !sidebarToggle.contains(e.target)) {
                sidebar.classList.remove('show');
            }
        }
    });
}

// User menu functionality
function initializeUserMenu() {
    const userMenuToggle = document.querySelector('.user-menu-toggle');
    const userMenuDropdown = document.querySelector('.user-menu-dropdown');
    
    if (userMenuToggle && userMenuDropdown) {
        userMenuToggle.addEventListener('click', function(e) {
            e.preventDefault();
            userMenuDropdown.classList.toggle('show');
        });
        
        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            if (!userMenuToggle.contains(e.target) && !userMenuDropdown.contains(e.target)) {
                userMenuDropdown.classList.remove('show');
            }
        });
    }
}

// Image upload functionality
function initializeImageUpload() {
    const uploadAreas = document.querySelectorAll('.image-upload-area');
    
    uploadAreas.forEach(area => {
        const input = area.querySelector('input[type="file"]');
        const preview = area.parentElement.querySelector('.image-preview');
        
        if (input) {
            // Click to upload
            area.addEventListener('click', () => input.click());
            
            // Drag and drop
            area.addEventListener('dragover', handleDragOver);
            area.addEventListener('dragleave', handleDragLeave);
            area.addEventListener('drop', (e) => handleDrop(e, input));
            
            // File input change
            input.addEventListener('change', (e) => handleFileSelect(e, preview));
        }
    });
}

function handleDragOver(e) {
    e.preventDefault();
    e.currentTarget.classList.add('dragover');
}

function handleDragLeave(e) {
    e.preventDefault();
    e.currentTarget.classList.remove('dragover');
}

function handleDrop(e, input) {
    e.preventDefault();
    e.currentTarget.classList.remove('dragover');
    
    const files = e.dataTransfer.files;
    input.files = files;
    
    const preview = e.currentTarget.parentElement.querySelector('.image-preview');
    handleFileSelect({ target: input }, preview);
}

function handleFileSelect(e, preview) {
    const files = e.target.files;
    
    if (preview) {
        preview.innerHTML = '';
        
        Array.from(files).forEach((file, index) => {
            if (file.type.startsWith('image/')) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    const previewItem = createImagePreviewItem(e.target.result, index);
                    preview.appendChild(previewItem);
                };
                reader.readAsDataURL(file);
            }
        });
    }
}

function createImagePreviewItem(src, index) {
    const item = document.createElement('div');
    item.className = 'image-preview-item';
    item.innerHTML = `
        <img src="${src}" alt="Preview ${index + 1}">
        <button type="button" class="image-preview-remove" onclick="removeImagePreview(this)">
            ×
        </button>
    `;
    return item;
}

function removeImagePreview(button) {
    button.parentElement.remove();
}

// Form handling
function initializeForms() {
    const forms = document.querySelectorAll('form[data-ajax="true"]');
    
    forms.forEach(form => {
        form.addEventListener('submit', handleAjaxForm);
    });
}

async function handleAjaxForm(e) {
    e.preventDefault();
    
    const form = e.target;
    const submitButton = form.querySelector('button[type="submit"]');
    const originalText = submitButton.textContent;
    
    // Show loading state
    submitButton.disabled = true;
    submitButton.innerHTML = '<span class="spinner"></span> Salvando...';
    
    try {
        const formData = new FormData(form);
        const response = await fetch(form.action, {
            method: form.method,
            body: formData
        });
        
        const result = await response.json();
        
        if (result.success) {
            showAlert('success', result.message || 'Operação realizada com sucesso!');
            
            // Reset form if it's a create form
            if (form.dataset.reset === 'true') {
                form.reset();
                document.querySelector('.image-preview')?.innerHTML = '';
            }
            
            // Reload data table if exists
            if (typeof loadTableData === 'function') {
                loadTableData();
            }
        } else {
            showAlert('danger', result.message || 'Erro ao processar solicitação');
        }
    } catch (error) {
        console.error('Form submission error:', error);
        showAlert('danger', 'Erro interno do servidor');
    } finally {
        // Restore button state
        submitButton.disabled = false;
        submitButton.textContent = originalText;
    }
}

// Data tables functionality
function initializeDataTables() {
    const tables = document.querySelectorAll('[data-table="true"]');
    
    tables.forEach(table => {
        const tableType = table.dataset.tableType;
        
        if (tableType) {
            loadTableData(tableType);
        }
    });
}

async function loadTableData(type = 'tourist-points', page = 1, limit = 10, filters = {}) {
    const tableBody = document.querySelector(`[data-table-type="${type}"] tbody`);
    const pagination = document.querySelector(`[data-pagination="${type}"]`);
    
    if (!tableBody) return;
    
    // Show loading
    tableBody.innerHTML = '<tr><td colspan="100%" class="text-center">Carregando...</td></tr>';
    
    try {
        const queryParams = new URLSearchParams({
            page,
            limit,
            ...filters
        });
        
        const response = await fetch(`/api/${type}?${queryParams}`);
        const result = await response.json();
        
        if (result.success) {
            renderTableData(tableBody, result.data, type);
            renderPagination(pagination, result.pagination, type);
        } else {
            tableBody.innerHTML = '<tr><td colspan="100%" class="text-center text-danger">Erro ao carregar dados</td></tr>';
        }
    } catch (error) {
        console.error('Error loading table data:', error);
        tableBody.innerHTML = '<tr><td colspan="100%" class="text-center text-danger">Erro interno do servidor</td></tr>';
    }
}

function renderTableData(tbody, data, type) {
    if (data.length === 0) {
        tbody.innerHTML = '<tr><td colspan="100%" class="text-center">Nenhum registro encontrado</td></tr>';
        return;
    }
    
    tbody.innerHTML = '';
    
    data.forEach(item => {
        const row = createTableRow(item, type);
        tbody.appendChild(row);
    });
}

function createTableRow(item, type) {
    const row = document.createElement('tr');
    
    switch (type) {
        case 'tourist-points':
            row.innerHTML = `
                <td>
                    ${item.imageUrls && item.imageUrls.length > 0 
                        ? `<img src="${item.imageUrls[0]}" alt="${item.name?.pt || 'Imagem'}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">`
                        : '<div style="width: 50px; height: 50px; background: #f8f9fa; border-radius: 4px; display: flex; align-items: center; justify-content: center;"><i class="fas fa-image text-muted"></i></div>'
                    }
                </td>
                <td>
                    <strong>${item.name?.pt || 'Sem nome'}</strong><br>
                    <small class="text-muted">${item.category || 'Sem categoria'}</small>
                </td>
                <td>${item.address?.pt || 'Sem endereço'}</td>
                <td>
                    <span class="badge ${item.isActive ? 'bg-success' : 'bg-secondary'}">
                        ${item.isActive ? 'Ativo' : 'Inativo'}
                    </span>
                </td>
                <td>
                    <div class="btn-group btn-group-sm">
                        <a href="/dashboard/tourist-points/edit/${item.id}" class="btn btn-outline-primary">
                            <i class="fas fa-edit"></i>
                        </a>
                        <button class="btn btn-outline-danger" onclick="deleteItem('tourist-points', '${item.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            `;
            break;
            
        case 'events':
            row.innerHTML = `
                <td>
                    ${item.imageUrls && item.imageUrls.length > 0 
                        ? `<img src="${item.imageUrls[0]}" alt="${item.title?.pt || 'Imagem'}" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;">`
                        : '<div style="width: 50px; height: 50px; background: #f8f9fa; border-radius: 4px; display: flex; align-items: center; justify-content: center;"><i class="fas fa-image text-muted"></i></div>'
                    }
                </td>
                <td>
                    <strong>${item.title?.pt || 'Sem título'}</strong><br>
                    <small class="text-muted">${item.category || 'Sem categoria'}</small>
                    ${item.isFeatured ? '<span class="badge bg-warning ms-1">Destaque</span>' : ''}
                </td>
                <td>
                    ${formatDate(item.startDate)} - ${formatDate(item.endDate)}
                </td>
                <td>${item.location || 'Online'}</td>
                <td>
                    <span class="badge ${item.isActive ? 'bg-success' : 'bg-secondary'}">
                        ${item.isActive ? 'Ativo' : 'Inativo'}
                    </span>
                </td>
                <td>
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-primary" onclick="editEvent('${item.id}')">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-outline-danger" onclick="deleteItem('events', '${item.id}')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </td>
            `;
            break;
    }
    
    return row;
}

function renderPagination(container, pagination, type) {
    if (!container || !pagination) return;
    
    const { page, pages, total } = pagination;
    
    let paginationHTML = `
        <div class="d-flex justify-content-between align-items-center">
            <div>
                Mostrando ${((page - 1) * pagination.limit) + 1} a ${Math.min(page * pagination.limit, total)} de ${total} registros
            </div>
            <div class="btn-group">
    `;
    
    // Previous button
    paginationHTML += `
        <button class="btn btn-outline-secondary ${page <= 1 ? 'disabled' : ''}" 
                onclick="loadTableData('${type}', ${page - 1})" 
                ${page <= 1 ? 'disabled' : ''}>
            Anterior
        </button>
    `;
    
    // Page numbers
    const startPage = Math.max(1, page - 2);
    const endPage = Math.min(pages, page + 2);
    
    for (let i = startPage; i <= endPage; i++) {
        paginationHTML += `
            <button class="btn ${i === page ? 'btn-primary' : 'btn-outline-secondary'}" 
                    onclick="loadTableData('${type}', ${i})">
                ${i}
            </button>
        `;
    }
    
    // Next button
    paginationHTML += `
        <button class="btn btn-outline-secondary ${page >= pages ? 'disabled' : ''}" 
                onclick="loadTableData('${type}', ${page + 1})" 
                ${page >= pages ? 'disabled' : ''}>
            Próximo
        </button>
    `;
    
    paginationHTML += '</div></div>';
    
    container.innerHTML = paginationHTML;
}

// Modal functionality
function initializeModals() {
    const modals = document.querySelectorAll('.modal');
    
    modals.forEach(modal => {
        const closeButtons = modal.querySelectorAll('[data-dismiss="modal"]');
        
        closeButtons.forEach(button => {
            button.addEventListener('click', () => closeModal(modal));
        });
        
        // Close on backdrop click
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                closeModal(modal);
            }
        });
    });
}

function showModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'block';
        document.body.classList.add('modal-open');
    }
}

function closeModal(modal) {
    if (typeof modal === 'string') {
        modal = document.getElementById(modal);
    }
    
    if (modal) {
        modal.style.display = 'none';
        document.body.classList.remove('modal-open');
    }
}

// Dashboard statistics
async function loadDashboardStats() {
    const statsContainer = document.querySelector('.stats-grid');
    
    if (!statsContainer) return;
    
    try {
        const response = await fetch('/api/statistics');
        const result = await response.json();
        
        if (result.success) {
            updateStatsCards(result.data);
        }
    } catch (error) {
        console.error('Error loading dashboard stats:', error);
    }
}

function updateStatsCards(stats) {
    const cards = {
        'tourist-points': stats.touristPoints || 0,
        'events': stats.events || 0,
        'users': stats.users || 0,
        'reviews': stats.reviews || 0
    };
    
    Object.entries(cards).forEach(([key, value]) => {
        const card = document.querySelector(`[data-stat="${key}"] h3`);
        if (card) {
            card.textContent = value.toLocaleString();
        }
    });
}

// Utility functions
function showAlert(type, message, duration = 5000) {
    const alertContainer = document.getElementById('alert-container') || createAlertContainer();
    
    const alert = document.createElement('div');
    alert.className = `alert alert-${type} alert-dismissible`;
    alert.innerHTML = `
        ${message}
        <button type="button" class="btn-close" onclick="this.parentElement.remove()"></button>
    `;
    
    alertContainer.appendChild(alert);
    
    // Auto remove after duration
    setTimeout(() => {
        if (alert.parentElement) {
            alert.remove();
        }
    }, duration);
}

function createAlertContainer() {
    const container = document.createElement('div');
    container.id = 'alert-container';
    container.style.cssText = 'position: fixed; top: 20px; right: 20px; z-index: 9999; max-width: 400px;';
    document.body.appendChild(container);
    return container;
}

function formatDate(dateString) {
    if (!dateString) return '-';
    
    const date = new Date(dateString);
    return date.toLocaleDateString('pt-BR');
}

function formatDateTime(dateString) {
    if (!dateString) return '-';
    
    const date = new Date(dateString);
    return date.toLocaleString('pt-BR');
}

// Delete functionality
async function deleteItem(type, id) {
    if (!confirm('Tem certeza que deseja excluir este item?')) {
        return;
    }
    
    try {
        const response = await fetch(`/api/${type}/${id}`, {
            method: 'DELETE'
        });
        
        const result = await response.json();
        
        if (result.success) {
            showAlert('success', result.message || 'Item excluído com sucesso!');
            loadTableData(type);
        } else {
            showAlert('danger', result.message || 'Erro ao excluir item');
        }
    } catch (error) {
        console.error('Delete error:', error);
        showAlert('danger', 'Erro interno do servidor');
    }
}

// Search functionality
function initializeSearch() {
    const searchInputs = document.querySelectorAll('[data-search]');
    
    searchInputs.forEach(input => {
        let timeout;
        
        input.addEventListener('input', function() {
            clearTimeout(timeout);
            
            timeout = setTimeout(() => {
                const tableType = this.dataset.search;
                const searchTerm = this.value.trim();
                
                currentFilters.search = searchTerm;
                loadTableData(tableType, 1, currentLimit, currentFilters);
            }, 500);
        });
    });
}

// Filter functionality
function applyFilters(type) {
    const filterForm = document.querySelector(`[data-filter="${type}"]`);
    
    if (filterForm) {
        const formData = new FormData(filterForm);
        currentFilters = Object.fromEntries(formData.entries());
        
        loadTableData(type, 1, currentLimit, currentFilters);
    }
}

function clearFilters(type) {
    const filterForm = document.querySelector(`[data-filter="${type}"]`);
    
    if (filterForm) {
        filterForm.reset();
        currentFilters = {};
        
        loadTableData(type, 1, currentLimit, currentFilters);
    }
}

// Export functionality
async function exportData(type, format = 'csv') {
    try {
        const response = await fetch(`/api/${type}/export?format=${format}`);
        
        if (response.ok) {
            const blob = await response.blob();
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `${type}_${new Date().toISOString().split('T')[0]}.${format}`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
        } else {
            showAlert('danger', 'Erro ao exportar dados');
        }
    } catch (error) {
        console.error('Export error:', error);
        showAlert('danger', 'Erro interno do servidor');
    }
}

// Initialize search and filters when page loads
document.addEventListener('DOMContentLoaded', function() {
    initializeSearch();
});
