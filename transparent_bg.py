import os
from PIL import Image

folder = 'assets/poses'
if not os.path.exists(folder):
    print("Folder not found.")
    exit(0)

for filename in os.listdir(folder):
    if filename.endswith('.png'):
        path = os.path.join(folder, filename)
        try:
            img = Image.open(path).convert('RGBA')
            data = img.getdata()
            new_data = []
            
            # Use top-left pixel as background color reference
            bg_color = data[0]
            # Define a threshold to catch slight AI variations
            threshold = 20
            
            for item in data:
                # Calculate distance from background color
                r_diff = abs(item[0] - bg_color[0])
                g_diff = abs(item[1] - bg_color[1])
                b_diff = abs(item[2] - bg_color[2])
                
                # If it's very close to the background color -> fully transparent
                if r_diff < threshold and g_diff < threshold and b_diff < threshold:
                    new_data.append((255, 255, 255, 0))
                else:
                    # Antialiasing: For pixels somewhat close to bg, scale transparency
                    diff = max(r_diff, g_diff, b_diff)
                    if diff < threshold + 30:
                        alpha = int(((diff - threshold) / 30.0) * 255)
                        new_data.append((item[0], item[1], item[2], alpha))
                    else:
                        new_data.append(item)
            
            img.putdata(new_data)
            img.save(path, 'PNG')
            print(f"Processed {filename}")
        except Exception as e:
            print(f"Failed to process {filename}: {e}")
