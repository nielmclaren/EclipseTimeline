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

    private PImage _image;
    private float _radius;

    private int _numPointsW;
    private int _numPointsH_2pi; 
    private int _numPointsH;

    private float[] _coorX;
    private float[] _coorY;
    private float[] _coorZ;
    private float[] _multXZ;

    TextureSphere(PImage image, float radius) {
        _image = image;
        _radius = radius;
        ptsW = 30;
        ptsH = 30;
        
        // Parameters below are the number of vertices around the width and height
        initializeSphere(ptsW, ptsH);
    }

    void draw(PGraphics g) {
        g.pushMatrix();
        textureSphere(g, _radius, _radius, _radius, _image);
        g.popMatrix();
    }

    private void initializeSphere(int numPtsW, int numPtsH_2pi) {
        // The number of points around the width and height
        _numPointsW=numPtsW+1;
        _numPointsH_2pi=numPtsH_2pi;  // How many actual pts around the sphere (not just from top to bottom)
        _numPointsH=ceil((float)_numPointsH_2pi/2)+1;  // How many pts from top to bottom (abs(....) b/c of the possibility of an odd numPointsH_2pi)

        _coorX=new float[_numPointsW];   // All the x-coor in a horizontal circle radius 1
        _coorY=new float[_numPointsH];   // All the y-coor in a vertical circle radius 1
        _coorZ=new float[_numPointsW];   // All the z-coor in a horizontal circle radius 1
        _multXZ=new float[_numPointsH];  // The radius of each horizontal circle (that you will multiply with coorX and coorZ)

        for (int i=0; i<_numPointsW ;i++) {  // For all the points around the width
            float thetaW=i*2*PI/(_numPointsW-1);
            _coorX[i]=sin(thetaW);
            _coorZ[i]=cos(thetaW);
        }
        
        for (int i=0; i<_numPointsH; i++) {  // For all points from top to bottom
                if (int(_numPointsH_2pi/2) != (float)_numPointsH_2pi/2 && i==_numPointsH-1) {  // If the _numPointsH_2pi is odd and it is at the last pt
                float thetaH=(i-1)*2*PI/(_numPointsH_2pi);
                _coorY[i]=cos(PI+thetaH); 
                _multXZ[i]=0;
            } 
            else {
                //The numPointsH_2pi and 2 below allows there to be a flat bottom if the numPointsH is odd
                float thetaH=i*2*PI/(_numPointsH_2pi);

                //PI+ below makes the top always the point instead of the bottom.
                _coorY[i]=cos(PI+thetaH); 
                _multXZ[i]=sin(thetaH);
            }
        }
    }

    private void textureSphere(PGraphics g, float rx, float ry, float rz, PImage t) { 
        // These are so we can map certain parts of the image on to the shape 
        float changeU=t.width/(float)(_numPointsW-1); 
        float changeV=t.height/(float)(_numPointsH-1); 
        float u=0;  // Width variable for the texture
        float v=0;  // Height variable for the texture

        g.noStroke();
        g.beginShape(TRIANGLE_STRIP);
        g.texture(t);
        for (int i=0; i<(_numPointsH-1); i++) {  // For all the rings but top and bottom
            // Goes into the array here instead of loop to save time
            float coory=_coorY[i];
            float cooryPlus=_coorY[i+1];

            float multxz=_multXZ[i];
            float multxzPlus=_multXZ[i+1];

            for (int j=0; j<_numPointsW; j++) { // For all the pts in the ring
                g.normal(-_coorX[j]*multxz, -coory, -_coorZ[j]*multxz);
                g.vertex(_coorX[j]*multxz*rx, coory*ry, _coorZ[j]*multxz*rz, u, v);
                g.normal(-_coorX[j]*multxzPlus, -cooryPlus, -_coorZ[j]*multxzPlus);
                g.vertex(_coorX[j]*multxzPlus*rx, cooryPlus*ry, _coorZ[j]*multxzPlus*rz, u, v+changeV);
                u+=changeU;
            }
            v+=changeV;
            u=0;
        }
        g.endShape();
    }
}