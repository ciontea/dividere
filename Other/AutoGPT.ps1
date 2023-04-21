#Purpose: To install and configure AutoGPT for you
#Note: Please make sure Python is installed on your computer before running

#Variables to change before running
$stableAutoGPT = "https://github.com/Significant-Gravitas/Auto-GPT.git" #Recommended over master since AutoGPT reported that Master has issues occasionally
$MasterAutoGPT = "https://github.com/Significant-Gravitas/Auto-GPT.git"
$downloadPath = "C:\Users\David\Documents\AutoGPT"
$openAPIKey = ‘’
$elevenLabsAPIKey = ''

#Script start
New-Item -ItemType Directory -Path $downloadPath #Creating folder to store AutoGPT
python.exe -m pip install --upgrade pip #Updating Pip for Python
Cd $downloadPath #Changing directory to the download path to store the AutoGPT files here
Git clone $stableAutoGPT #Downloading AutoGPT
Pip install -r $downloadPath\Auto-GPT\requirements.txt #Installing other AutoGPT requirements defined by AutoGPT
Rename-Item $downloadPath\Auto-GPT\.env.template $downloadPath\Auto-GPT\.env #Renaming the file as per AutoGPT instructions
#Adding the API Keys as defined by variables
(Get-Content -Path "$downloadPath\Auto-GPT\.env") -replace "OPENAI_API_KEY=your-openai-api-key", "OPENAI_API_KEY=$openAPIKey" | Set-Content -Path "$downloadPath\Auto-GPT\.env"
(Get-Content -Path "$downloadPath\Auto-GPT\.env") -replace "ELEVENLABS_API_KEY=your-elevenlabs-api-key", "ELEVENLABS_API_KEY=$elevenLabsAPIKey" | Set-Content -Path "$downloadPath\Auto-GPT\.env"
