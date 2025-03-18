
// using structure

struct Particle {
    float pos[3];
    float mass;

    float get_pos_x(){
        return pos[0];
    }

    void reset_pos(){
        pos[0] = 0.;
        pos[1] = 0.;
        pos[2] = 0.;
    }
};

// this 

int main(){

    float pos_x[100];
    float pos_y[100];

    return 0;
}

// can be rewritten as

int main(){

    Particle particles[100];

    particles[0].pos[0]; // or particles[0].get_pos_x()
    particles[0].mass;

    particles[0].reset_pos();

    return 0;
}

// struc and class are very similar in C++ but slightly different
// operations inside the class (e.g. float get_pos_x() ) cannot be called outside 
// it can be done if we write "public:"

class Particle {

 public:   
    float pos[3];
    float mass;

    float get_pos_x(){
        return pos[0];
    }

    void reset_pos(){
        pos[0] = 0.;
        pos[1] = 0.;
        pos[2] = 0.;
    }

    void foo();
};

void Particle::foo() {
    pos[0] += pos[0];
}