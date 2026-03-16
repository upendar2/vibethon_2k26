<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>About IT&CA - Andhra University College of Engineering</title>
    
    <%-- Fonts and Icons --%>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    
    <link rel="stylesheet" href="about.css">
</head>
<body>

    <%-- Include the header --%>
    <%@ include file="/header/header.jsp" %>

    <%-- Main content area --%>
    <main class="main-content">
        <div class="about-container">
            
            <div class="program-header">
                <i class="fa-solid fa-network-wired"></i>
                <h1>Department of Information Technology & Computer Applications (IT&CA)</h1>
                <p>A premier hub of technical excellence under Andhra University College of Engineering (A), dedicated to shaping the future of IT professionals.</p>
            </div>
        
            <h2><i class="fa-solid fa-building-columns"></i> About the Department</h2>
            <ul class="program-details">
                <li>Established as a distinct department to meet the growing global demand for high-end IT and Software Engineering professionals.</li>
                <li>Housed within the prestigious AU College of Engineering (Autonomous), it offers a blend of rigorous academics and cutting-edge technical training.</li>
                <li>The department serves as a bridge between foundational computer science and modern industrial application development.</li>
            </ul>
        
            <h2><i class="fa-solid fa-bullseye"></i> Department Objectives</h2>
            <ul class="program-details check-list">
                <li>To deliver high-quality education in IT and Computer Applications through a modern, industry-relevant curriculum.</li>
                <li>To foster an environment of research and innovation in emerging areas like Cloud Computing, AI, and Cybersecurity.</li>
                <li>To bridge the gap between academia and industry through regular workshops, internships, and technical collaborations.</li>
                <li>To cultivate ethical leadership and professional integrity among students entering the global technology workforce.</li>
            </ul>
        
            <h2><i class="fa-solid fa-microchip"></i> Core Areas of Expertise</h2>
            <ul class="program-details grid-list">
                <li>Full-Stack Web Technologies</li>
                <li>Enterprise Resource Planning (ERP)</li>
                <li>Mobile Application Development</li>
                <li>Cybersecurity & Digital Forensics</li>
                <li>Big Data Analytics & Data Engineering</li>
                <li>Internet of Things (IoT) Systems</li>
                <li>Agile Software Development Methodologies</li>
                <li>Network Security & Administration</li>
            </ul>
        
            <h2><i class="fa-solid fa-server"></i> Salient Features</h2>
            <ul class="program-details check-list">
                <li>State-of-the-art specialized laboratories with high-speed computing clusters.</li>
                <li>Strong alumni network placed in Tier-1 Global IT companies (MNCs).</li>
                <li>Regular Guest Lectures from industry veterans and international researchers.</li>
                <li>Focus on Project-Based Learning (PBL) throughout the curriculum.</li>
                <li>Autonomous status allowing for rapid curriculum updates aligned with Silicon Valley trends.</li>
                <li>Active placement cell with a consistent track record of securing high-package offers.</li>
            </ul>
        
            <h2><i class="fa-solid fa-user-tie"></i> Career Pathways</h2>
            <ul class="program-details grid-list">
                <li>IT Infrastructure Manager</li>
                <li>System Architect / Lead Developer</li>
                <li>Cloud Solutions Engineer</li>
                <li>Information Security Analyst</li>
                <li>Software Quality Assurance Lead</li>
                <li>Data Scientist / AI Engineer</li>
                <li>Technical Consultant</li>
            </ul>
        
            <h2><i class="fa-solid fa-award"></i> Why Choose IT&CA at AUCE?</h2>
            <ul class="program-details check-list">
                <li>Legacy of Excellence: Part of Andhra University, a NAAC A++ accredited institution with a 100-year history.</li>
                <li>Strategic Location: Situated in Visakhapatnam, a growing IT hub, offering proximity to tech parks and startups.</li>
                <li>Holistic Growth: Integration of technical clubs, hackathons, and cultural events for all-round development.</li>
                <li>Competitive Edge: Training provided for national-level competitive exams and global certifications.</li>
            </ul>
        
            <h2><i class="fa-solid fa-eye"></i> Vision</h2>
            <p>To be a globally recognized center of excellence in Information Technology and Computer Applications, empowering students to lead innovation and drive the digital transformation of society.</p>

            <h2><i class="fa-solid fa-compass"></i> Mission</h2>
            <p>To provide transformative education through advanced pedagogy, industry-aligned research, and a commitment to producing technically proficient and socially responsible IT leaders.</p>

            <h2><i class="fa-solid fa-images"></i> Department Gallery</h2>
            <div class="photo-gallery">
                <img src="https://i.postimg.cc/Z559PmvY/4.jpg" alt="Advanced IT Lab" onerror="this.src='https://placehold.co/800x400/1f2937/white?text=IT+Lab'">
                <img src="https://i.postimg.cc/Nf3sFw8x/cse.jpg" alt="Department Building" onerror="this.src='https://placehold.co/800x400/1f2937/white?text=ITCA+Department'">
                <img src="https://i.postimg.cc/5Nssxxwj/MAN02662-342129290.jpg" alt="AUCE Campus" onerror="this.src='https://placehold.co/800x400/3b82f6/white?text=AUCE+Campus'">
                <img src="https://i.postimg.cc/6Q34LXSC/MAN02945-2029073282.jpg" alt="Smart Classroom" onerror="this.src='https://placehold.co/800x400/6b7280/white?text=Smart+Classroom'">
                <img src="https://i.postimg.cc/3x73HFFx/MAN02953-2002291173.jpg" alt="Seminar Hall" onerror="this.src='https://placehold.co/800x400/3b82f6/white?text=Seminar+Hall'">
                <img src="https://i.postimg.cc/SQ684qBf/12.jpg" alt="Innovation Hub" onerror="this.src='https://placehold.co/800x400/3b82f6/white?text=Innovation+Hub'">
            </div>
            
        </div>
    </main>

    <%-- Include the footer --%>
    <%@ include file="/header/footer.jsp" %>

</body>
</html>