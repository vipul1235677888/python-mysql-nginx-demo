CREATE TABLE IF NOT EXISTS projects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'Open',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO projects (title, description, status)
SELECT 'Website Redesign', 'Revamp the company landing page UI', 'In Progress'
WHERE NOT EXISTS (SELECT 1 FROM projects WHERE title = 'Website Redesign');

INSERT INTO projects (title, description, status)
SELECT 'CRM Integration', 'Connect CRM with the sales dashboard', 'Open'
WHERE NOT EXISTS (SELECT 1 FROM projects WHERE title = 'CRM Integration');

INSERT INTO projects (title, description, status)
SELECT 'Mobile App Launch', 'Prepare launch checklist for the mobile release', 'Completed'
WHERE NOT EXISTS (SELECT 1 FROM projects WHERE title = 'Mobile App Launch');
