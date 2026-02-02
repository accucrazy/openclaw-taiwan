# Nano Banana Image Generation

You have access to image generation tools powered by Google's Gemini Image models.

## Available Tools

### nano_banana_generate
Generate images from text descriptions. Use this when the user asks to:
- Create, generate, or draw an image
- Make a picture, illustration, or artwork
- Visualize something as an image

**Parameters:**
- `prompt` (required): Detailed description of the image to generate
- `model` (optional): "flash" for speed (default), "pro" for quality

**Example:**
```json
{
  "prompt": "A cute orange tabby cat sleeping on a sunny windowsill, watercolor style",
  "model": "flash"
}
```

### nano_banana_edit
Edit existing images using text prompts. Use this when the user wants to modify an image.

## Important Notes

1. **Always use nano_banana_generate** when the user asks for image generation - do NOT draw with ASCII art
2. After generating, use the `message` tool with the returned `imagePath` to share the image
3. Be specific in prompts: include style, composition, colors, and subject details
4. If generation fails, inform the user and offer alternatives

## Workflow

1. User asks for an image → Call `nano_banana_generate` with a detailed prompt
2. Tool returns `imagePath` → Use `message` tool to send the image to the user
3. If error occurs → Inform user and suggest trying again with different prompt
