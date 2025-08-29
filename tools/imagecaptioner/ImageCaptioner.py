import sys
from PIL import Image, ImageDraw, ImageFont
import os

def caption_image(input_path, output_path, caption_text):
    img = Image.open(input_path)
    width, height = img.size

    # Add space at top
    caption_height = max(100, int(height * 0.25))  # extra room for multiple lines
    new_img = Image.new("RGB", (width, height + caption_height), color=(0, 0, 0))
    new_img.paste(img, (0, caption_height))

    draw = ImageDraw.Draw(new_img)
    try:
        font = ImageFont.truetype("arial.ttf", size=int(caption_height * 0.2))
    except:
        font = ImageFont.load_default()

    # Wrap text to fit image width
    max_width = width * 0.9  # leave some margin
    lines = []
    words = caption_text.split()
    line = ""
    for word in words:
        test_line = f"{line} {word}".strip()
        bbox = draw.textbbox((0,0), test_line, font=font)
        text_width = bbox[2] - bbox[0]
        if text_width <= max_width:
            line = test_line
        else:
            lines.append(line)
            line = word
    lines.append(line)

    # Draw each line
    total_text_height = sum(draw.textbbox((0,0), l, font=font)[3] - draw.textbbox((0,0), l, font=font)[1] for l in lines)
    current_y = (caption_height - total_text_height)/2

    for l in lines:
        bbox = draw.textbbox((0,0), l, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        text_x = (width - text_width)/2

        # Outline
        outline_range = 2
        for dx in range(-outline_range, outline_range+1):
            for dy in range(-outline_range, outline_range+1):
                draw.text((text_x+dx, current_y+dy), l, font=font, fill=(0,0,0))
        draw.text((text_x, current_y), l, font=font, fill=(255,255,255))

        current_y += text_height

    # Save
    new_img.save(output_path)
    print(f"Saved captioned image as {output_path}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: ImageCaptioner.py input.png [output.png] [caption]")
    else:
        input_path = sys.argv[1]
        output_path = sys.argv[2] if len(sys.argv) > 2 else "output.png"
        caption_text = sys.argv[3] if len(sys.argv) > 3 else "HELLO WORLD"
        caption_image(input_path, output_path, caption_text)



