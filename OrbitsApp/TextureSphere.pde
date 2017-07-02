/**
 * Texture Sphere 
 * by Gillian Ramsay
 * 
 * Rewritten by Gillian Ramsay to better display the poles.
 * Previous version by Mike 'Flux' Chang (and cleaned up by Aaron Koblin). 
 * Original based on code by Toxi.
 * 
 * A 3D textured sphere with simple rotation control.
 */
 
class TextureSphere {
    private int ptsW, ptsH;

    private PImage img;

    private int numPointsW;
    private int numPointsH_2pi; 
    private int numPointsH;

    private float[] coorX;
    private float[] coorY;
    private float[] coorZ;
    private float[] multXZ;

    TextureSphere() {
        img = loadImage("map.jpg");
        ptsW = 30;
        ptsH = 30;
        
        // Parameters below are the number of vertices around the width and height
        initializeSphere(ptsW, ptsH);
    }

    // Use arrow keys to change detail settings
    void keyPressed() {
        if (keyCode == ENTER) saveFrame();
        if (keyCode == UP) ptsH++;
        if (keyCode == DOWN) ptsH--;
        if (keyCode == LEFT) ptsW--;
        if (keyCode == RIGHT) ptsW++;
        if (ptsW == 0) ptsW = 1;
        if (ptsH == 0) ptsH = 2;
        // Parameters below are the number of vertices around the width and height
        initializeSphere(ptsW, ptsH);
    }

    void draw(PGraphics g) {
        g.pushMatrix();
        textureSphere(g, 60, 60, 60, img);
        g.popMatrix();
    }

    private void initializeSphere(int numPtsW, int numPtsH_2pi) {
        // The number of points around the width and height
        numPointsW=numPtsW+1;
        numPointsH_2pi=numPtsH_2pi;  // How many actual pts around the sphere (not just from top to bottom)
        numPointsH=ceil((float)numPointsH_2pi/2)+1;  // How many pts from top to bottom (abs(....) b/c of the possibility of an odd numPointsH_2pi)

        coorX=new float[numPointsW];   // All the x-coor in a horizontal circle radius 1
        coorY=new float[numPointsH];   // All the y-coor in a vertical circle radius 1
        coorZ=new float[numPointsW];   // All the z-coor in a horizontal circle radius 1
        multXZ=new float[numPointsH];  // The radius of each horizontal circle (that you will multiply with coorX and coorZ)

        for (int i=0; i<numPointsW ;i++) {  // For all the points around the width
            float thetaW=i*2*PI/(numPointsW-1);
            coorX[i]=sin(thetaW);
            coorZ[i]=cos(thetaW);
        }
        
        for (int i=0; i<numPointsH; i++) {  // For all points from top to bottom
                if (int(numPointsH_2pi/2) != (float)numPointsH_2pi/2 && i==numPointsH-1) {  // If the numPointsH_2pi is odd and it is at the last pt
                float thetaH=(i-1)*2*PI/(numPointsH_2pi);
                coorY[i]=cos(PI+thetaH); 
                multXZ[i]=0;
            } 
            else {
                //The numPointsH_2pi and 2 below allows there to be a flat bottom if the numPointsH is odd
                float thetaH=i*2*PI/(numPointsH_2pi);

                //PI+ below makes the top always the point instead of the bottom.
                coorY[i]=cos(PI+thetaH); 
                multXZ[i]=sin(thetaH);
            }
        }
    }

    private void textureSphere(PGraphics g, float rx, float ry, float rz, PImage t) { 
        // These are so we can map certain parts of the image on to the shape 
        float changeU=t.width/(float)(numPointsW-1); 
        float changeV=t.height/(float)(numPointsH-1); 
        float u=0;  // Width variable for the texture
        float v=0;  // Height variable for the texture

        g.noStroke();
        g.beginShape(TRIANGLE_STRIP);
        g.texture(t);
        for (int i=0; i<(numPointsH-1); i++) {  // For all the rings but top and bottom
            // Goes into the array here instead of loop to save time
            float coory=coorY[i];
            float cooryPlus=coorY[i+1];

            float multxz=multXZ[i];
            float multxzPlus=multXZ[i+1];

            for (int j=0; j<numPointsW; j++) { // For all the pts in the ring
                g.normal(-coorX[j]*multxz, -coory, -coorZ[j]*multxz);
                g.vertex(coorX[j]*multxz*rx, coory*ry, coorZ[j]*multxz*rz, u, v);
                g.normal(-coorX[j]*multxzPlus, -cooryPlus, -coorZ[j]*multxzPlus);
                g.vertex(coorX[j]*multxzPlus*rx, cooryPlus*ry, coorZ[j]*multxzPlus*rz, u, v+changeV);
                u+=changeU;
            }
            v+=changeV;
            u=0;
        }
        g.endShape();
    }
}