// Show/Hide sections
function showSection(section) {
    const catalogSection = document.getElementById('catalog-section');
    const apiSection = document.getElementById('api-testing-section');
    
    if (section === 'catalog') {
        catalogSection.classList.remove('hide');
        apiSection.classList.add('hide');
        loadCatalogData();
    } else {
        catalogSection.classList.add('hide');
        apiSection.classList.remove('hide');
    }
}

// Load catalog data
async function loadCatalogData() {
    try {
        const response = await fetch('/api/test-data');
        const data = await response.json();
        
        populateMembersTable(data.members);
        populateBooksTable(data.books);
        populateLoansTable(data.loans);
    } catch (error) {
        console.error('Error loading catalog data:', error);
    }
}

// Populate members table
function populateMembersTable(members) {
    const tbody = document.getElementById('members-tbody');
    
    if (!members || members.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="empty-state">No members found</td></tr>';
        return;
    }
    
    tbody.innerHTML = members.map(member => `
        <tr>
            <td>${member.member_id}</td>
            <td>${member.first_name} ${member.last_name}</td>
            <td>${member.email}</td>
            <td>${member.current_borrow_count || 0}</td>
            <td>${member.has_overdue_books ? '⚠️ Yes' : '✓ No'}</td>
        </tr>
    `).join('');
}

// Populate books table
function populateBooksTable(books) {
    const tbody = document.getElementById('books-tbody');
    
    if (!books || books.length === 0) {
        tbody.innerHTML = '<tr><td colspan="5" class="empty-state">No books found</td></tr>';
        return;
    }
    
    tbody.innerHTML = books.map(book => `
        <tr>
            <td>${book.book_id}</td>
            <td><strong>${book.title}</strong></td>
            <td>${book.isbn}</td>
            <td>${book.genre || 'N/A'}</td>
            <td>
                <span class="badge ${book.available_copies > 0 ? 'badge-available' : 'badge-borrowed'}">
                    ${book.available_copies} available
                </span>
            </td>
        </tr>
    `).join('');
}

// Populate loans table
function populateLoansTable(loans) {
    const tbody = document.getElementById('loans-tbody');
    
    if (!loans || loans.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6" class="empty-state">No active loans</td></tr>';
        return;
    }
    
    tbody.innerHTML = loans.map(loan => {
        const borrowDate = new Date(loan.borrow_date).toLocaleDateString();
        const dueDate = new Date(loan.due_date).toLocaleDateString();
        const isOverdue = new Date(loan.due_date) < new Date();
        
        return `
            <tr>
                <td>${loan.loan_id}</td>
                <td>${loan.member_id}</td>
                <td>${loan.copy_id}</td>
                <td>${borrowDate}</td>
                <td>${dueDate}</td>
                <td>
                    <span class="badge ${isOverdue ? 'badge-borrowed' : 'badge-available'}">
                        ${isOverdue ? '⚠️ Overdue' : '✓ Active'}
                    </span>
                </td>
            </tr>
        `;
    }).join('');
}

// Test endpoint with result display
async function testEndpoint(id, url) {
    const resultDiv = document.getElementById(`result-${id}`);
    resultDiv.style.display = 'block';
    resultDiv.innerHTML = '<div class="loading">Loading...</div>';
    
    try {
        const response = await fetch(url);
        const data = await response.json();
        
        if (response.ok) {
            resultDiv.innerHTML = `
                <div class="success">✓ Success (${response.status})</div>
                <pre>${JSON.stringify(data, null, 2)}</pre>
            `;
        } else {
            resultDiv.innerHTML = `
                <div class="error">✗ Error (${response.status})</div>
                <pre>${JSON.stringify(data, null, 2)}</pre>
            `;
        }
    } catch (error) {
        resultDiv.innerHTML = `
            <div class="error">✗ Error</div>
            <pre>${error.message}</pre>
        `;
    }
}

// Test borrow book endpoint
async function testBorrowBook() {
    const resultDiv = document.getElementById('result-borrow');
    resultDiv.style.display = 'block';
    resultDiv.innerHTML = '<div class="loading">Loading...</div>';
    
    try {
        const response = await fetch('/api/borrowings', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ bookId: 1 })
        });
        const data = await response.json();
        
        if (response.ok) {
            resultDiv.innerHTML = `
                <div class="success">✓ Success (${response.status})</div>
                <pre>${JSON.stringify(data, null, 2)}</pre>
            `;
        } else {
            resultDiv.innerHTML = `
                <div class="error">✗ Error (${response.status})</div>
                <pre>${JSON.stringify(data, null, 2)}</pre>
            `;
        }
    } catch (error) {
        resultDiv.innerHTML = `
            <div class="error">✗ Error</div>
            <pre>${error.message}</pre>
        `;
    }
}

// Test return book endpoint
async function testReturnBook() {
    const resultDiv = document.getElementById('result-return');
    resultDiv.style.display = 'block';
    resultDiv.innerHTML = '<div class="loading">Loading...</div>';
    
    try {
        const response = await fetch('/api/borrowings/1/return', {
            method: 'PUT'
        });
        const data = await response.json();
        
        if (response.ok) {
            resultDiv.innerHTML = `
                <div class="success">✓ Success (${response.status})</div>
                <pre>${JSON.stringify(data, null, 2)}</pre>
            `;
        } else {
            resultDiv.innerHTML = `
                <div class="error">✗ Error (${response.status})</div>
                <pre>${JSON.stringify(data, null, 2)}</pre>
            `;
        }
    } catch (error) {
        resultDiv.innerHTML = `
            <div class="error">✗ Error</div>
            <pre>${error.message}</pre>
        `;
    }
}

// Auto-load catalog on page load
window.addEventListener('load', () => {
    loadCatalogData();
});
