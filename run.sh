set -e

speaker=llg
stage=$1
dir=dataset_tmp/$speaker
mkdir -p $dir

if [ ${stage} == 1 ]; then
  python autoslice.py --idir $dir/source --odir $dir/cut || exit -1
  pushd $dir/cut
  find . | grep 'wav' | nl -nrz -w3 -v1 | while read n f; do mv "$f" "${speaker}_$n.wav"; done || exit -1
  popd
fi

if [ ${stage} == 2 ]; then
  export TF_FORCE_GPU_ALLOW_GROWTH=true
  spleeter separate -o $dir/clean -p spleeter:2stems $dir/cut/*.wav || exit -1
fi
if [ ${stage} == 3 ]; then
  pushd $dir/clean 
  echo * | tr ' ' '\n' | while read f; do mv $f/vocals.wav $f.wav; done || exit -1
  mkdir -p ../clean2
  mv *.wav ../clean2/
  rm -rf ./*
  popd
fi
if [ ${stage} == 4 ]; then
  python autoslice2.py --ag 3 --in_path $dir/clean2 || exit -1
fi
if [ ${stage} == 5 ]; then
  mkdir -p dataset_raw/$speaker/
  mv $dir/split/*.wav dataset_raw/$speaker/
fi

if [ ${stage} == 6 ] ; then
	python resample.py
	python preprocess_flist_config.py
fi
if [ ${stage} == 7 ] ; then
	python preprocess_hubert_f0.py
fi
if [ ${stage} == 8 ] ; then
	python train.py -c configs/config.json -m 32k
fi



