# Gaussian Talker Implementation (Get started rapidly).

### Built the Docker Image.
```bash
git clone https://github.com/KevinDayve/GaussianTalker.git
cd GaussianTalker
docker build -t gaussian-talker:v1 .
```

### Run the Container.
```bash
docker run -itd --gpus=all --ipc=host \
  -v ~/git/GaussianTalker:/root/GaussianTalker \
  --name gaussian_env \
  gaussian-talker:v1 /bin/bash

docker exec -it gaussian_env bash
```

### Step 3: Download Assets.
* 3D morphable model.
  > Download from [here](https://drive.google.com/drive/folders/1i3wT4lICxiw4oyLRZ9ZYoeLbEu3LZbhP?usp=sharing)
  > Place `01_MorphableModel.mat` inside:
  ```bash
  data_utils/face_tracking/3DMM/
  ```
  > Convert it into BFM using:
  ```bash
  cd data_utils/face_tracking
  python3 convert_BFM.py
  cd ../../
  ```
* Face parsing model
  ```bash
  cd data_utils/face_parsing/
  wget https://huggingface.co/OwlMaster/AllFilesRope/resolve/main/79999_iter.pth
  ```
* Download Sample Video (OBAMA):
  ```bash
  mkdir -p ~/git/GaussianTalker/data/obama
  cd ~/git/GaussianTalker/data/obama
  wget "https://github.com/YudongGuo/AD-NeRF/blob/master/dataset/vids/Obama.mp4?raw=true" -O obama.mp4
  ```

### Step 4: Preprocess the input video.
If Obama:
```bash
cd /root/GaussianTalker
python3 data_utils/process.py data/obama/obama.mp4
```

If not obama:
```bash
python3 data_utils/process.py data/yourvideo/yourvideo.mp4 --downgrade True
```

### Step 5: (From the host machine). AU feature extraction.
```bash
docker run -it --rm \
  -v ~/git/GaussianTalker:/data \
  algebr/openface:latest
```

###### Inside the OpenFace Container.
```bash
cd /data/data/obama
/home/openface-build/build/bin/FeatureExtraction -f obama.mp4
mv obama.csv au.csv
```

### Step 6: Train the Model.
```bash
python3 train.py \
  -s data/obama \
  --model_path models/obama \
  --configs arguments/64_dim_1_transformer.py
```

### Step 7: Inference with Custom audio
```bash
python3 scripts/process_audio.render.py --name {Name}
```

```bash
python render.py \
  -s data/obama \
  --model_path models/obama \
  --configs arguments/64_dim_1_transformer.py \
  --iteration 10000 \
  --batch 1 \
  --custom_aud data/{Name}/{Name}_talk.npy \
  --custom_wav data/{Name}/{Name_talk.wav \
  --skip_train --skip_test
```

### Auxillery Steps;
* Clean Entry / Exit
  ```bash
  docker stop gaussian_env
  ```
  > RE-Enter:
  ```bash
  docker start gaussian_env
  docker exec -it gaussian_env bash
  ```

* ⚠️ TroubleShoot
  * * If OOM Errors during Process.py : use `--downgrade`
    * Missing `diff_gaussian_rasterization`:
      ```bash
      export PYTHONPATH=$PYTHONPATH:/root/GaussianTalker/submodules/custom-bg-depth-diff-gaussian-rasterization
      ```

#### Maintainer:
**Maintained with ♥️ by @KevinDayve**
  
