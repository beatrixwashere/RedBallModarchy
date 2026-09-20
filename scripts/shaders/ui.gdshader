shader_type canvas_item;
const float bthick = 0.1;
const float bstrength = 0.6;
uniform float rwidth = 1.0;
uniform float rheight = 1.0;
bool incircle(float xpos, float ypos) {
	return (xpos*xpos)*rwidth*rwidth+(ypos*ypos)*rheight*rheight < bthick/2.0;
}
void fragment() {
	float lboundw = bthick/rwidth;
	float rboundw = 1.0-lboundw;
	float lboundh = bthick/rheight;
	float rboundh = 1.0-lboundh;
	bool edges = UV.x < lboundw || UV.x > rboundw || UV.y < lboundh || UV.y > rboundh;
	bool circles = incircle(UV.x, UV.y) || incircle(UV.x-1.0, UV.y) || incircle(UV.x, UV.y-1.0) || incircle(UV.x-1.0, UV.y-1.0);
	if(edges || circles) {
		COLOR.rgb += vec3(bstrength,bstrength,bstrength);
	}
	//float pos = (UV.x+UV.y)/2.0;
	//COLOR.rgb += vec3(pos,pos/2.0,pos/2.0);
}