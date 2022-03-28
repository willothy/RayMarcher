#define MAX_STEPS 100
#define MAX_DIST 100.0
#define SURF_DIST 0.01

float GetDist(vec3 p) {
    vec4 s = vec4(2, 0, 5, .9);
    //vec4 c = vec4(2.4, 0, 5, 1);
    
    float sphereDist = length(p - s.xyz) - s.w;
    float planeDist = p.y; //length(max(abs(p - c.xyz) - c.w , 0.0));
    
    float d = max(sphereDist, planeDist);// - (sin(iTime)-.1);
    return d;
}

float RayMarch(vec3 ro, vec3 rd) {
    float distToOrigin = 0.0;
    
    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * distToOrigin;
        float distToScene = GetDist(p);
        distToOrigin += distToScene;
        if (distToOrigin > MAX_DIST || distToScene < SURF_DIST) break;
    }
    
    return distToOrigin;
}

vec3 GetNormal(vec3 p) {
    float d = GetDist(p);
    vec2 e = vec2(0.1, 0);
    
    vec3 normal = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx)
    );
    
    return normalize(normal);
}

float GetLight(vec3 p) {
    vec3 lightPos = vec3(0, 3, 5);
    lightPos.xz += vec2(sin(iTime), cos(iTime));
    vec3 l = normalize(lightPos - p);
    vec3 normal = GetNormal(p);
    
    float diffuse = clamp(dot(normal, l), 0.0, 1.0);
    float d = RayMarch(p+normal*(SURF_DIST+.01), l);
    if (d < length(lightPos - p)) diffuse *= .1;
    return diffuse;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;

    // Time varying pixel color
    vec3 col = vec3(0);
    
    // Ray Origin
    vec3 ro = vec3(0, 1, 0);
    // Ray Direction
    vec3 rd = normalize(vec3(uv.x, uv.y, 1));

    float d = RayMarch(ro, rd);
    
    vec3 p = ro + rd * d;
    
    float diffuse = GetLight(p);
    col = vec3(diffuse);
    fragColor = vec4(col,1.0);
}







