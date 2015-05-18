; ==========================================================================================
; Vertex shader for rendering the scene to the back buffer using simple texture mapping.
; ==========================================================================================
; 
m44   op,    va0,   vc0         ; Output the transformed vertices (worldSpace -> clipSpace)
mov   v0,    va1                ; Pass the UV coordinates needed for simple texture mapping.