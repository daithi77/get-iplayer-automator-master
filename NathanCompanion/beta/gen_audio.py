"""Fetch Aine (ABAIR, Ulster) for every text in data/audio_texts.json into audio/<id>.mp3.
Patient: 2 s between calls; when ABAIR is down, wait a minute and try again. Stops after MAX_HOURS."""
import json, hashlib, base64, subprocess, time, os, urllib.parse, sys
MAX_HOURS=float(sys.argv[1]) if len(sys.argv)>1 else 4
texts=json.load(open('data/audio_texts.json'))
if os.path.exists('data/audio_texts_gcse.json'): texts+=[t for t in json.load(open('data/audio_texts_gcse.json')) if t not in texts]
if os.path.exists('data/audio_texts_a2.json'): texts+=[t for t in json.load(open('data/audio_texts_a2.json')) if t not in texts]
def aid(t): return hashlib.sha1(t.strip().encode()).hexdigest()[:12]
os.makedirs('audio',exist_ok=True)
start=time.time(); todo=[t for t in texts if not os.path.exists(f'audio/{aid(t)}.mp3')]
print('to do',len(todo),flush=True)
while todo and time.time()-start<MAX_HOURS*3600:
    t=todo[0]; out=f'audio/{aid(t)}.mp3'
    q=urllib.parse.urlencode({'input':t,'voice':'ga_UL_anb_piper','normalise':'true'})
    r=subprocess.run(['curl','-s','-m','45','-w','\n%{http_code}','https://synthesis.abair.ie/api/synthesise?'+q],capture_output=True)
    body,_,code=r.stdout.rpartition(b'\n')
    try:
        assert code==b'200'
        wav=f'/tmp/a_{os.getpid()}.wav'; open(wav,'wb').write(base64.b64decode(json.loads(body)['audioContent']))
        subprocess.run(['ffmpeg','-y','-loglevel','error','-i',wav,'-ac','1','-b:a','48k',out],check=True)
        todo.pop(0); print('ok',len(texts)-len(todo),'/',len(texts),flush=True); time.sleep(2)
    except Exception:
        print(time.strftime('%H:%M'),'abair not answering',code.decode(errors='ignore'),'- waiting 60s',flush=True); time.sleep(60)
print('DONE' if not todo else f'STOPPED with {len(todo)} left',flush=True)
