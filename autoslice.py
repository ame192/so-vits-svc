import subprocess
import os
import argparse
def get_duration(filename):
    result = subprocess.run(["ffprobe","-v","error", "-show_entries",
                             "format=duration","-of","default=noprint_wrappers=1:nokey=1",filename],
                            stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    return float(result.stdout)

def process(args):
    idir = args.idir
    odir = args.odir
    vlist = os.listdir(idir)
    dX = 600
    for ifn in vlist:
        duration = get_duration(os.path.join(idir, ifn))
        idx = 0
        x0 = 0
        for i in range (0, int(duration+1), dX):
            x1 = x0 + dX
            fn, _ = os.path.splitext(ifn)
            fn = str(fn) + "_" + str(idx) 
            idx += 1
            cmd = 'ffmpeg -i "{}" -ss {} -to {} -ac 1 -ar 32000 -f wav "{}"'.format(
                os.path.join(idir,ifn), x0, x1, os.path.join(odir,str(fn))+'.wav'
            )
            os.system(cmd)
            x0 = x1

if __name__ == '__main__':
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument("--idir",type=str, required=True)
    parser.add_argument("--odir",type=str, required=True)
    args = parser.parse_args()

    if not os.path.exists(args.odir):
        os.mkdir(args.odir)

    process(args)

