import os
import re
import subprocess
from argparse import ArgumentParser

def read_envs_from_file(file_path):
    """
    Read environment variables from a text file with one per line.
    
    :param file_path: str, The path to the file containing environment variable names.
    :return: list, A list of environment variable names to be replaced.
    """
    envs_to_modify = []
    try:
        with open(file_path, 'r') as f:
            for line in f:
                env_name = line.strip()
                if env_name:
                    envs_to_modify.append(env_name)
        return envs_to_modify
    except FileNotFoundError:
        print(f"File not found: {file_path}")
        return []

def modify_lua_content(content, envs_to_modify):
    """
    Modify environment variable references in Lua content by prepending APPTAINERENV_.
    
    :param content: str, The Lua file content as a string.
    :param envs_to_modify: list, Environment variable names to be prefixed.
    :return: str, The modified Lua file content.
    """

    """
    Determine if system is running singularity or apptainer
    """

    output = subprocess.check_output(["singularity", "help"]).decode("utf-8")
    global env_regex
    if 'apptainer' in output:
      env_regex = "APPTAINERENV_"
    else:
      env_regex = "SINGULARITYENV_"
    for env in envs_to_modify:
        # Create regex pattern for variables with double quotes
        pattern = rf'"{env}"'
        modified_content = re.sub(pattern, f'"{env_regex}{env}"', content)
        if modified_content != content:
            content = modified_content
    
    return content

def copy_and_modify_lua_files(output_dir, vars_file):
    """
    Copy all Lua files from the source directory to a new output directory,
    modifying them by prepending APPTAINERENV_ or SINGULARITYENV to specified environment variables.
    
    :param output_dir: str, The path to the output directory where modified Lua files will be saved.
    :param vars_file: str, The path to the file containing environment variable names.
    """
    source_dir = "./.modulefiles"
    try:
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
        
        for root, _, files in os.walk(source_dir):
            for file in files:
                if file.endswith(".lua"):
                    file_path = os.path.join(root, file)
                    with open(file_path, 'r') as f:
                        content = f.read()
                    
                    modified_content = modify_lua_content(content, read_envs_from_file(vars_file))
                    
                    # Determine the output file path relative to the source directory
                    relative_path = os.path.relpath(file_path, source_dir)
                    output_file_path = os.path.join(output_dir, relative_path)
                    
                    # Ensure the correct parent directories exist
                    os.makedirs(os.path.dirname(output_file_path), exist_ok=True)
                    
                    with open(output_file_path, 'w') as f:
                        f.write(modified_content)
        
        print("Modified Lua files have been saved to the specified output directory.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    parser = ArgumentParser(description="Modify Lua environment variable references")
    parser.add_argument("-i", "--container-image", dest="img", required=True,
                        help="Path to the singularity image file containing spack-stack")
    parser.add_argument("-o", "--output-dir", dest="output_dir", required=True,
                        help="Path to the output directory for modified Lua files")
    
    args = parser.parse_args()
    #set the img as an environment variable
    os.environ['img'] = args.img
    #get the basename of PWD to bind with singularity
    command = "dirname $PWD | awk -F'/' '{print $2}'"
    basepath = "/"+os.popen(command).read().strip()+" "


    #get the spack-stack version
    command =  'singularity exec $img ls /opt/spack-stack'
    spack_stack_ver = os.popen(command).read().strip()
    # copy the all the modulefiles out of the container image
    # remove any old .modulefiles in place
    os.system("rm -rf ./.modulefiles")
    command = "singularity exec -e -B "+basepath+args.img+" cp -r /opt/spack-stack/"+spack_stack_ver+"/envs/unified-env/install/modulefiles ./.modulefiles"
    os.system(command)

    # get a list of all the files that contain either setenv, or _path
    os.system("grep -R setenv .modulefiles/* | awk -F '\"' '{print $2}' | sort | uniq > .envs")
    os.system("grep -R _path .modulefiles/* | awk -F '\"' '{print $2}' | sort | uniq >> .envs")
    os.system("sed -i '/MODULEPATH/d' .envs")
    # walk through all the files and change variables to contain APPTAINERENV_ or SINGULARITYENV_
    copy_and_modify_lua_files(args.output_dir, ".envs")

    # get the stack type (intel v oneapi)
    stack_type=os.popen("ls ./.modulefiles/Core").read().strip()
    compiler_type=stack_type.split("-")[1]

    # get the original module path from the lua file
    command = 'grep MODULEPATH ./.modulefiles/Core/'+stack_type+'/*.lua | awk -F \'"\' \'{print $4}\''
    spack_stack_path = os.popen(command).read().strip()

    parts = spack_stack_path.split('/')
    modulefiles_index = parts.index("modulefiles")
    parts[:modulefiles_index + 1] = [args.output_dir]
    new_path = '/'.join(parts)
   
#   compiler_ver = os.popen("ls ./modulefiles/"+compiler_type).read().strip()
#   path_list = [args.output_dir,compiler_type,compiler_ver]
#   delimiter = "/"
#   new_path = delimiter.join(path_list)
    command ="grep -R -l MODULEPATH "+args.output_dir+"/Core | xargs sed -i 's|"+spack_stack_path+"|"+new_path+"|g'"
    os.system(command)

    # get the origin module path for the mpi module
    command = 'grep -R MODULEPATH ./.modulefiles/'+compiler_type+'/*/stack-* | awk -F \'"\' \'{print $4}\' | head -n 1'
    mpi_stack_path = os.popen(command).read().strip()
    print("using this modulepath to grep",mpi_stack_path)
    # replace the original path with the new path on the host system
    parts = mpi_stack_path.split('/')
    modulefiles_index = parts.index("modulefiles")
    parts[:modulefiles_index + 1] = [args.output_dir]
    new_path = '/'.join(parts)
    command ="grep -R -l MODULEPATH "+args.output_dir+"/"+compiler_type+" | xargs sed -i 's|"+mpi_stack_path+"|"+new_path+"|g'"
    os.system(command)

    #set some basic paths inside the container that also include the location of ifort, icc, and icpc
    lua_file_path = args.output_dir+"/Core/"+stack_type+"/*.lua"
    container_path = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local"

    command = "grep ENV_F77 "+lua_file_path+" | awk -F '\"' '{print $4}' | xargs dirname"
    container_path = container_path+":"+os.popen(command).read().strip()
    command = "grep ENV_CC "+lua_file_path+" | awk -F '\"' '{print $4}' | xargs dirname"
    container_path = container_path+":"+os.popen(command).read().strip()

    stack_intel_lua_file = args.output_dir+'/Core/'+stack_type+'/*.lua'
    command = f"sed -i '/prereq/a setenv(\"{env_regex}PATH\",\""+container_path+"\")' "+stack_intel_lua_file
    os.system(command)
    #set path on host system to $PWD/args.output_dir/bin, which is where the gen tools will be placed
    local_path = args.output_dir+"/bin"
    os.system("mkdir "+local_path)
    new_line = 'prepend_path("PATH","'+local_path+'")'
    sed_command = f'sed -i \'/ENV_PATH/a {new_line}\' {stack_intel_lua_file}'
    os.system(sed_command)

    # some lua systems are incompatable with depends_on, so change that to load. It is slower, but works
    command = "grep -Ri -l depends_on "+args.output_dir+"/* | xargs sed -i 's/depends_on/load/g'"
    os.system(command)
    # generate the build tools locally in $PWD/bin. This path will be added to the path set in stack-intel module
    command = "singularity exec -B "+basepath+" -e $img /opt/container-scripts/gen-build-tools.sh -e "+local_path
    os.system(command)
#   os.system("rm -rf ./.modulefiles")

    #put make-external in the bin path
    command = "singularity exec -B "+basepath+" $img cp /opt/container-scripts/make-external "+local_path
    os.system(command)

    #special cases for prod_util and wgrib2, which both get called directly from various workflow scripts
    #externalize wgrib2 and put it in local_path from above
    #get full path to wgrib2 from module file
    command = "grep -Ri wgrib2_ROOT "+args.output_dir+" | awk -F '\"' '{print $4}'"
    print(command)
    wgrib2 = os.popen(command).read().strip()+"/bin/wgrib2"
    command = "singularity exec -B /"+args.output_dir+" $img cp "+wgrib2+" "+local_path
    print(command)
    os.system(command)

    # externalize it
    command = local_path+"/make-external "+local_path+"/wgrib2" 
    print(command)
    os.system(command)

    #get full path to prod_util
    command = "grep -Ri prod_util_ROOT "+args.output_dir+" | awk -F '\"' '{print $4}'"
    print(command)
    prod_util_path = os.popen(command).read().strip()+"/bin/"
    binfiles = ["fsync_file", "mdate", "ndate", "nhour"]
    asciifiles= ["compath.py","cpfs","cpreq","date2jday.sh","err_chk","err_exit","finddate.sh","getjsonvalue","getsystem","mail.py","postmsg","prep_step","setpdy.sh","startmsg"]
    for file in asciifiles:
       command = "singularity exec -B "+basepath+" $img cp "+prod_util_path+file+" "+local_path
       print(command)
       os.system(command)

    for file in binfiles:
       command = "singularity exec -B "+basepath+" $img cp "+prod_util_path+file+" "+local_path
       os.system(command)
       command = local_path+"/make-external "+local_path+"/"+file
       print(command)
       os.system(command)

