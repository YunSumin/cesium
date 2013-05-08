uniform sampler2D u_texture;
//uniform float u_avgLuminance;

uniform float u_threshold;
uniform float u_offset;

varying vec2 v_textureCoordinates;

float key(float avg)
{
    float guess = 1.5 - (1.5 / (avg * 0.1 + 1.0));
    return max(0.0, guess) + 0.1;
}

mat3 RGB2XYZ = mat3(0.4124, 0.2126, 0.0193,
                    0.3576, 0.7152, 0.1192,
                    0.1805, 0.0722, 0.9505);
mat3 XYZ2RGB = mat3(3.2405, -0.9693, 0.0556,
                    -1.5371, 1.8760, -0.2040,
                    -0.4985, 0.0416, 1.0572);
                    
vec3 rgbToXYZ(vec3 rgb)
{
    vec3 xyz = RGB2XYZ * rgb;
    vec3 Yxy;
    Yxy.r = xyz.g;
    float temp = dot(vec3(1.0), xyz);
    Yxy.gb = xyz.rg / temp;
    return Yxy;
}

vec3 xyzToRGB(vec3 Yxy)
{
    vec3 xyz;
    xyz.r = Yxy.r * Yxy.g / Yxy.b;
    xyz.g = Yxy.r;
    xyz.b = Yxy.r * (1.0 - Yxy.g - Yxy.b) / Yxy.b;
    
    return XYZ2RGB * xyz;
}

void main()
{
    //float avgLuminance = texture2D(u_avgLuminance, vec2(0.0)).r;
    float avgLuminance = 0.5;
    vec4 color = texture2D(u_texture, v_textureCoordinates);
    vec3 xyz = rgbToXYZ(color.rgb);
    float luminance = xyz.r;
    
    float scaledLum = key(avgLuminance) * luminance / avgLuminance;
    float brightLum = max(scaledLum - u_threshold, 0.0);
    float brightness = brightLum / (u_offset + brightLum);
    
    xyz.r = brightness;
    gl_FragColor = vec4(xyzToRGB(xyz), 1.0);
}
