shader_type canvas_item;
render_mode unshaded;

uniform lowp float Spacing_Factor : hint_range(1, 100, 1) = 4;
uniform lowp float Height : hint_range(0, 20) = 0.0;
uniform lowp float Height_Per_Major : hint_range(1, 100) = 5.0;
uniform lowp float Minor_Line_Size : hint_range(0, 1) = 0.25;
uniform lowp float Major_Line_Size : hint_range(0, 1) = 0.75;
uniform lowp float Thickness : hint_range(0, 1) = 0.4;

void fragment() {
  if (Minor_Line_Size < 0.0001 && Major_Line_Size < 0.0001) discard;
  if (Thickness < 0.0001) discard;
   
  lowp float centering_offset = Thickness * 0.5 * Spacing_Factor;
  // -UV.y makes the lines go downwards as the height increases.
  lowp float h = -UV.y * Spacing_Factor + centering_offset + (Height / (Height_Per_Major / Spacing_Factor));

  // -UV.x makes the lines rest on the right side.
  // invert this sign to change direction.
  lowp vec2 pos = vec2(-UV.x, h);
  pos -= floor(pos); // fract() is avoided to improve OpenGL compatibility.

  // setting up between which lines are major and which ones are minor.
  lowp vec2 interval = vec2(
    mod(h - (Thickness * (Spacing_Factor)) - 1.0, Spacing_Factor),
    mod(h - (Thickness * (Spacing_Factor)) - 1.0, Spacing_Factor)
  );

  if (pos.y >= interval.r) 
    pos.x += 1.0 - Major_Line_Size;
  else 
    pos.x += 1.0 - Minor_Line_Size;

  lowp vec2 pos_major = pos;
  pos_major.y /= Spacing_Factor;

  // vertical crop
  bool vgap = pos.y < 1.0 - Thickness;
  if (vgap) 
    discard;

  // horizontal crop
  bvec2 hgap = bvec2(
    pos_major.x > (1.0 - Major_Line_Size),
    pos.x > (1.0 - Minor_Line_Size)
  );
  if (hgap.x && hgap.y) 
    discard;
}