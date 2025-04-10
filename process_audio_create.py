import sounddevice as sd
from scipy.io.wavfile import write
import argparse
import os
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument("--name", required=True, help='Name of the subject folder inside data/')
parser.add_argument("--duration", type=int, default=5, help='Duration in seconds')
arguments = parser.parse_args()

sampleRate = 16000
channels = 1
folder = f"data/{args.name}/"
os.makedirs(folder, exist_ok=True)

print(f'Recording {args.duration}s of audio to {folder}aud_novel_wav')
recording = sd.rec(args.duration * sampleRate, samplerate=sampleRate, channels=channels, dtype='int16')
sd.wait()

wavPath = os.path.join(folder, "aud_novel.wav")
write(wavPath, sampleRate, recording)

#Convert to .npy using --task2
print("Extracting deepspeech features")
subprocess.run(["python3", "data_utils/process.py", "--task", "2", folder], check=True)

print('Ready to use custom audio with rendered models.)
