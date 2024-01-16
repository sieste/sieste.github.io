let logicConcepts = []; // Stores the JSON data
let currentConcept = [];
let isConceptRevealed = false; // Tracks the state of reveal


const conceptsListDiv = document.getElementById('conceptsList');
const conceptDiv = document.getElementById('concept');
const definitionDiv = document.getElementById('definition');
const exampleDiv = document.getElementById('example');
const revealButton = document.getElementById('reveal');

// Function to display a random example
function showRandomExample() {
    const randomIndex = Math.floor(Math.random() * logicConcepts.length);
    currentConcept = logicConcepts[randomIndex];
    conceptDiv.textContent = 'Concept: ' + currentConcept.concept;
    definitionDiv.textContent = 'Definition:';
    exampleDiv.textContent = 'Example:';
    isConceptRevealed = false; // Reset the reveal state
}

// Function to reveal the concept
function revealConcept() {
    //const currentConcept = logicConcepts.find(x => x.concept === conceptDiv.textContent);
    if (currentConcept) {
        definitionDiv.textContent = 'Definition: ' + currentConcept.definition;
        exampleDiv.textContent = 'Example: ' + currentConcept.example;
        isConceptRevealed = true; // Set the reveal state
    }
}

// Event listener for the reveal button
revealButton.addEventListener('click', () => {
    if (isConceptRevealed) {
        showRandomExample(); // Show a new example if the concept is already revealed
        revealButton.textContent = 'Reveal';
    } else {
        revealConcept(); // Reveal the concept if not yet revealed
        revealButton.textContent = 'Next';
    }
});

// Function to create and display the list
function displayConcepts() {
    logicConcepts.forEach(concept => {
        const conceptDiv = document.createElement('div');
        conceptDiv.className = 'concept-item';

        const conceptName = document.createElement('div');
        conceptName.className = 'concept-name';
        conceptName.textContent = concept.concept;
        conceptName.style.fontWeight = 'bold';
        conceptDiv.appendChild(conceptName);

        const conceptDefinition = document.createElement('div');
        conceptDefinition.className = 'concept-definition';
        conceptDefinition.textContent = 'Definition: ' + concept.definition;
        conceptDiv.appendChild(conceptDefinition);

        const conceptExample = document.createElement('div');
        conceptExample.className = 'concept-example';
        conceptExample.textContent = 'Example: ' + concept.example;
        conceptDiv.appendChild(conceptExample);

        conceptsListDiv.appendChild(conceptDiv);
    });
}

// Fetch the JSON data, store it in logicConcepts, and then display it
fetch('logic.json')
    .then(response => response.json())
    .then(data => {
        logicConcepts = data;
        displayConcepts();
        showRandomExample();
    })
    .catch(error => console.error('Error fetching data:', error));

