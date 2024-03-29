#!/usr/bin/env python3

from glob import glob
import inspect
import io
import os
import pkgutil
import platform
import shutil
import subprocess
import sys
import tarfile
import urllib.request
import zipfile

fold = os.path.abspath(os.path.dirname(sys.argv[0]))
system = platform.system()


def path(*args):
    return os.path.expanduser(os.path.expandvars(os.path.join(*args)))


# Because windows is absurd and has no easy way to make symlinks.
# This also requires the script to be run as admin, since symlinks are restricted to admins
# How was that ever a good idea?
def symlink(source, link_name):
    os_symlink = getattr(os, "symlink", None)
    if callable(os_symlink):
        os_symlink(source, link_name)
    else:
        import ctypes

        csl = ctypes.windll.kernel32.CreateSymbolicLinkW
        csl.argtypes = (ctypes.c_wchar_p, ctypes.c_wchar_p, ctypes.c_uint32)
        csl.restype = ctypes.c_ubyte
        flags = 1 if os.path.isdir(source) else 0
        if csl(link_name, source, flags) == 0:
            raise ctypes.WinError()


def link(source, dest):
    source = os.path.join(fold, source)
    dest = path(dest)
    if os.path.exists(dest):
        print("{0} exists, not overwriting".format(dest))
    else:
        if os.path.lexists(dest):
            os.remove(dest)
        symlink(source, dest)
        print("{0} linked to {1}".format(dest, source))


def link_all_ipython():
    ipython_dir = path("~", ".ipython", "profile_default", "startup")
    if not os.path.exists(ipython_dir):
        os.makedirs(ipython_dir)

    for startup_file in glob(os.path.join("ipython_startup", "*.py")):
        script_name = os.path.basename(startup_file)
        link(startup_file, os.path.join(ipython_dir, script_name))


git_bin = (
    "git" if system in ["Linux", "Darwin"] else "c:/Program Files (x86)/Git/bin/git.exe"
)


def clone_git(url, outputDir):
    name = url[url.rfind("/") + 1 : url.rfind(".")]
    outputDir = os.path.join(path(outputDir), name)
    if os.path.exists(outputDir):
        print("{} exists, skipping".format(outputDir))
        return
    subprocess.call([git_bin, "clone", "--recursive", url, outputDir])
    print("Installed {}".format(outputDir))


def git_submodule_update():
    subprocess.call(
        [git_bin, "submodule", "update", "--init", "--recursive"],
        cwd=os.path.dirname(__file__),
    )


installed_pypackages = [name for _, name, _ in pkgutil.iter_modules()]


def installPyPackage(tarball):
    tarpath, filename = os.path.split(tarball)
    for name in installed_pypackages:
        if name in filename:
            print("{} installed already, skipping".format(name))
            return
    tar = tarfile.open(tarball, "r:gz")
    instpath = path(tarpath, tar.firstmember.name)
    tar.extractall(tarpath)
    subprocess.call(
        ["python", "setup.py", "install", "--user"],
        cwd=instpath,
        stdout=open(os.devnull, "wb"),
    )
    shutil.rmtree(instpath)
    print("Installed {0}".format(instpath))


def download_clangd():
    clangd_symlink = os.path.join(os.path.dirname(__file__), "bin", "clangd")
    clangd_loc = os.path.join(
        os.path.dirname(__file__), "bin", "clangd_16.0.2", "bin", "clangd"
    )
    if os.path.exists(clangd_symlink):
        return

    url = "https://github.com/clangd/clangd/releases/download/16.0.2/clangd-linux-16.0.2.zip"
    response = urllib.request.urlopen(url)
    contents = io.BytesIO(response.read())
    zipped = zipfile.ZipFile(contents)

    zipped.extractall(os.path.dirname(clangd_symlink))
    os.chmod(clangd_loc, 0o554)

    relpath = os.path.relpath(clangd_loc, os.path.dirname(clangd_symlink))
    os.symlink(relpath, clangd_symlink)


def add_bash_common():
    bashrc_path = os.path.expanduser("~/.bashrc")
    current_bashrc = ""
    if os.path.exists(bashrc_path):
        current_bashrc = open(bashrc_path).read()
    if ".bash_common" in current_bashrc:
        print(".bashrc already calls .bash_common, skipping")
    else:
        print("Adding .bash_common to .bashrc")
        bashrc = current_bashrc + inspect.cleandoc(
            """
        if [ -f ~/.bash_common ]; then . ~/.bash_common; fi
        """
        )
        with open(bashrc_path, "w") as f:
            f.write(bashrc)


dot_emacs_path = (
    "~" if system in ["Linux", "Darwin"] else path("~", "AppData", "Roaming")
)
emacs_dir = path(dot_emacs_path, ".emacs.d")
dot_emacs = path(dot_emacs_path, ".emacs")

git_submodule_update()

if system in ["Linux", "Darwin"]:
    link("dot_bash_common", "~/.bash_common")
    link("dot_screenrc", "~/.screenrc")
    link("dot_dir_colors", "~/.dir_colors")
    link("dot_tmux.conf", "~/.tmux.conf")
    link("dot_gitconfig", "~/.gitconfig")
    link("dot_Xdefaults", "~/.Xdefaults")
    link("dot_Xdefaults", "~/.Xresources")
    link("dot_gdbinit", "~/.gdbinit")
    link_all_ipython()
    add_bash_common()
    download_clangd()

link("pylib", "~/pylib")
link("dot_emacs", dot_emacs)
link("dot_emacs.d", emacs_dir)

# Not needed so much now that the lab has pip installed.
# for tarball in sorted(glob(path('pypackages','*.tar.gz'))+
#                       glob(path('pypackages','*.tgz'))):
#     installPyPackage(tarball)
