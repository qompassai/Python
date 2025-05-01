#!/bin/bash
# Save this as convert_pptx.sh in your DLI directory

base_dir="/home/phaedrus/.GH/Qompass/Equator/Python/5_NVIDIA/DLI"

# List of files to convert
files=(
  "Level 1 - Introduction to Generative AI/Lecture Slides/1.1-Introduction-to-GenAI.pptx"
  "Level 1 - Introduction to Generative AI/Lecture Slides/1.2-Historical-and-Future-Perspectives-of-GenAI.pptx"
  "Level 4 - Diffusion Models in Generative AI/Lecture Slides/6.1-Image-Generation-and-GANs.pptx"
  "Level 4 - Diffusion Models in Generative AI/Lecture Slides/6.2-UNets-and-Diffusion.pptx"
  "Level 4 - Diffusion Models in Generative AI/Lecture Slides/6.3-CLIP-and-Latent-Diffusion.pptx"
  "Level 6 - LLM Orchestration/Lecture Slides/8.1-LLM-Components.pptx"
  "Level 6 - LLM Orchestration/Lecture Slides/8.2-LLM-Compound-Systems.pptx"
  "Level 6 - LLM Orchestration/Lecture Slides/8.3-LLM-Agents.pptx"
)

# Convert each file
for file in "${files[@]}"; do
  dir=$(dirname "$file")
  echo "Converting $file..."
  libreoffice --headless --convert-to pdf "$base_dir/$file" --outdir "$base_dir/$dir"
done

echo "Conversion complete!"

