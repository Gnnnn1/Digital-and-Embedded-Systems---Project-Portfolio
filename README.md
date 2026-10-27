# ELIC 329- Digital and Embedded Systems - Project Portfolio Template

This repository contains a four-project report website built with GitHub Pages and Jekyll. Edit the Markdown files; no HTML is required.

## Step 1: Create repository from this template
1. Sign in to GitHub, if you haven't already
2. If you are seeing these instructions, you are already on the project template page you can copy from
3. Click **Use this template** on top-right of this repository page
4. Select **Create a new repository**.
5. Choose your account as owner. Name your repository, e.g. `digital-systems-portfolio`. Select **Public**, then create it.
You now have your own copy of the project report template

## Step 2: Enable GitHub pages
6. On your repository, go to **Settings >> Pages**.
7. Under **Build and deployment**, choose **Deploy from a branch**, select `main` and `/(root)`, then **Save**.
8. Wait for the published site link to appear under **Settings >> Pages**. Its typical address is `https://USERNAME.github.io/REPOSITORY_NAME/`.
9. Open `index.md`, click the pencil icon, replace the bracketed placeholders, and commit changes.
    
## Step 3: Complete your project reports
10. Open the projects folder. It contains four Markdown files:
    - project1.md
    - project2.md
    - project3.md
    - project4.md
    
10. Edit `projects/project1.md` through `projects/project4.md`. Preserve the YAML front matter (the lines between `---` at the top).
   For each project, include:
    - **Introduction:** Project idea and objectives
    - **Design:** Explanation of design and labelled block diagram
    - **Code:** Dexplanation of code blocks or sections (key parts), Link to the design source, testbench and relevant XDC
    - **Simulation:** Waveforms for all required scenarios and analysis of expected vs. observed results
    - **Hardware:** Elaborated and synthesized schematics, implementation, utilization and Basys3 behaviour
    - **Reflection:** Challenges/resolutions and learning linked to theory

11. Upload VHDL files, testbenches and XDC constraints to the corresponding `source/projectN/` folder.
12. Upload figures/screenshots/photos to `assets/projectN/`. Match the filenames used in the Markdown or update the image links.
13. Add working source links in each project's **Code** section. For example, a relative Markdown link from `projects/project1.md` to a repository file can be written as `[design.vhd](../source/project1/design.vhd)`;  

## Step 4: Verify Your Website
Before submitting:
    Check that all project pages open correctly.
    Verify that diagrams and screenshots are visible and readable.
    Confirm that links to source files work.
    Ensure that simulation results are explained, not simply displayed.
    Confirm that the hardware implementation and reflection sections are complete.

Submission
GitHub repository URL: The link to your source repository.
GitHub Pages URL: The link to your published project portfolio.
