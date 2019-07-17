" Variables -----------------------------------------

" Stores project information in the form 
" {project_name:['path':path,'files':[file1, file2, file3,...]}, ...}
let g:cpp_projects = {} 

" Settings (adjustable) ------------------------------

let g:add_buffer_when_making_new_project = 1
let s:current_project = ""

" Functions -------------------------------------------

function Run()
    let l:match_cpp = len(matchstr("%", "*.cpp\|*.hpp\|*.h")) 
    let l:match_py = len(matchstr("%", "*.py"))
    
    if l:match_cpp > 0    
        call RunCPP()
    elseif l:match_py >0
        call RunPython()
    else
        echo "Filetype is not supported."
        return 0
    endif
endfunction


function RunPython()
    " Save the open buffer
    w
    " Open a new window and run the current file
    ! "gnome-terminal --window --  python " + expand("%")

endfunction


function RunCPP()
    if len(s:current_project) == 0
        echo "Please specify your current project using the :SetCurrentProject command"
    else
        let l:current_project = g:cpp_projects[s:current_project]
        let l:working_directory = l:current_project['path']
        let l:project_files = join(l:current_project['files'], " ")

        if len(l:project_files) == 0
            echo "Your set project is empty. Use the :AddToProject command to add files to the current project."
        else
            " Save the open buffer
            w
            " Open a new window and compile the current CPP project
            ! "gnome-terminal --window -- g++ " + join(l:project_files, " ")
            echo "Compilation successful"
            " Run the compiled file
            ! "gnome-terminal --window --working-directory " + l:working_directory + " -- sh -c './a.out ; bash'"
        endif
    endif
endfunction


function MakeCPPProject(project_name)
    " Check to see whether or not the project already exists
    if get(g:cpp_projects, a:project_name) == 0
        " Add a new project to cpp_projects
        g:cpp_projects[a:project_name] = {"path":"", "files":[]}
        
        let l:files = g:cpp_projects[a:project_name]["files"]
        let l:path = g:cpp_projects[a:project_name]["path"]
        " Set the project path to the current working directory
        l:path = ! "cd .." 

        if g:add_buffer_when_making_project == 1
            " Add the current buffer to the new project
            l:files += [expand("%")] 
        elseif g:add_buffer_when_making_project == 0:
            " If the setting is off, do not add the current buffer to the new
            " project
        else
            echo "There may be something wrong with your settings. Make sure g:add_buffer_when_making_project is either 0 or 1."
        endif
    else
        echo "Project already exists. Use :RemoveCPPProject to remove from g:cpp_projects."
    endif

endfunction


" Accepts an undefined number of arguments in the form of filenames (if the
" file is in the project home directory) or filepaths (preferred)
function AddToCPPProject(...)
    if len(g:current_project) == 0
        echo "Please specify youre current project using the :SetCurrentCPPProject command"
    else
        "Save the current buffer
        w

        let l:to_add = a:00
        " Assign a copy of the current files in project to the variable
        " current_files
        let l:current_files = g:cpp_projects[g:current_project][:]
    
        for file in l:to_add
            if count(l:current_files, file) == 0
                let l:current_files = add(l:current_files, file)
            endif
        endfor

        let g:cpp_projects[g:current_project] = l:current_files + l:to_add
    endif

endfunction


function SetCurrentProject(project_name)
    if get(g:cpp_projects, a:project_name) != 0
        s:current_project = a:project_name
    else
        echo "Not a valid project name. Use :ShowCPPProjects to view a list of existing projects."
    endif
    
endfunction


function ShowCPPProjects()
    for project in g:cpp_projects
        echo "- " + project

        let l:project_files = g:cpp_projects[project]["files"]
        for file in l:project_files
            echo "--- " + file
        endfor
    endfor

endfunction


" Commands --------------------------------------------
command RunCPP call RunCPP()
command AddToCPPProject call AddToCPPProject()


" Mappings --------------------------------------------

