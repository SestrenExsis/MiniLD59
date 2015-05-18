; ==========================================================================================
; Fragment shader for rendering the scene to the back buffer using simple texture mapping.
; ==========================================================================================
; 
; fs0: Texture Atlas
;  v0: UV coordinates for texture mapping
;
tex   oc,        v0.xy,  fs0 <2d,nearest,nomip>