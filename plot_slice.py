    if block in ["POS ", "VEL "]:
        if len(data) % 3 == 0:
            data=data.reshape(int(len(data)/3),3)
        else:
            print("\nError: Data is not divisible by 3, can not split data")
            return None

    # Check if the length of the fata is equal to the number of particles
    if block in ["POS ", "VEL ", "ID  "] and len(data) != Nparticles:
        print("\nError: Data seems not correct. Shape:", len(data), " - Number particles:", Nparticles)

    return data



# ------------ MAIN ------------

nfile, Nparticles, Nparticles_file, gformat, swap, boxsize = read_header(filename)

if gformat in [1,2]:

    # Write additional messages during snapshot read
    verbose = 0

    # The block name should be for chars, add spaces to complete it, e.g. "POS " and not "POS"
    pos = extract_block(filename, "POS ", verbose = verbose)
    vel = extract_block(filename, "VEL ", verbose = verbose)
    mass = extract_block(filename, "MASS", verbose = verbose)
    pid = extract_block(filename, "ID  ", verbose = verbose)

#############################################################################################
#######  END OF THE READING ROUTINE: READY FOR PLOTTING OR FOR MASS ASSIGNMENT   ############
#############################################################################################

# We assign x, y, and z positions to three separate arrays
x=pos[:,0]
y=pos[:,1]
z=pos[:,2]

# We select only particles in a slice of thickness (2*thickness*boxsize)
# parallel to the x-y plane and centered in the middle of the simulation
# domain along the z axis
ind=np.where((abs(z-(boxsize*0.5)) < thickness*boxsize))

# We just plot the projected (x,y) positions of all particles as points
# Each particle is a point in the scatter plot
plt.scatter(x[ind],y[ind],marker='.', lw=0, s=1)

#plt.show()
plt.savefig(MODEL+'_slice.png',dpi=240)
