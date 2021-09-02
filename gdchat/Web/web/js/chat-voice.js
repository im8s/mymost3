var audio_context;
var recorder;

var time=1;
var timer;
var openUserMedia=false;
 var mediaStreamTrack;
function __log(e, data) {
    console.log( "\n" + e + " " + (data || ''));
  }
function startUserMedia(stream) {
    var input = audio_context.createMediaStreamSource(stream);
     __log('Media stream created.');

    // Uncomment if you want the audio to feedback directly
    input.connect(audio_context.destination);
    __log('Input connected to audio context destination.');

    recorder = new Recorder(input);
     __log('Recorder initialised.');
  }

  function startRecording() {

    recorder.record();
    time=1;
    timer=setInterval("timeOut()",1000);
    $("#voice_img").hide();
    $("#voice_gif").show();
    // button.disabled = true;
    // button.nextElementSibling.disabled = false;
     __log('Recording...');
  }

  function stopRecording() {

     window.clearInterval(timer);
     $("#voice_gif").hide();
     $("#voice_img").show();
    // button.previousElementSibling.disabled = false;
    // __log('Stopped recording.');
    mediaStreamTrack && mediaStreamTrack.stop();
    openUserMedia=false;
    // create WAV download link using audio data blob
    createDownloadLink();


    recorder.stop();
    recorder.clear();


  }

  function createDownloadLink() {
    if(myFn.isNil(recorder))
      return;
     recorder.exportWAV(function(blob) {
          var data = new FormData();

                data.append("userId",myData.userId);
                data.append('file', blob);
                data=WEBIM.createOpenApiSecret(data);
                // var xhr = new XMLHttpRequest();
                $.ajax({
                    contentType:"multipart/form-data",
                    type:"POST",
                    url:AppConfig.uploadVoiceUrl,
                    data:data,
                    dataType:"json",
                    processData:false,
                    contentType:false,
                    success:function(result){
                        var msg=WEBIM.createVoiceMessage(3, result["url"],1,time);
                        UI.sendMsg(msg);
                        $("#voice").modal("hide");
                        // audioData.buffer=[];
                        // audioData.size=0;
                        // context.close();
                    }
                });


    });
  }

function initUserMedia(init) {
  // init  是否 是初始化 加载  false 不是 true 是
    try {
      // webkit shim
      window.AudioContext = window.AudioContext || window.webkitAudioContext;
     navigator.getUserMedia = (navigator.getUserMedia ||
                         navigator.webkitGetUserMedia ||
                         navigator.mozGetUserMedia ||
                         navigator.msGetUserMedia);
      
      audio_context = new AudioContext();
       __log('Audio context set up.');
      __log('navigator.getUserMedia ' + (navigator.getUserMedia ? 'available.' : 'not present!'));
    } catch (e) {
      //__log(e);
      alert('No web audio support in this browser!');
    }

    navigator.getUserMedia(
                        { audio: true }, //只启用音频

                        function (stream) {
                          $("#voice").modal('show');
                         mediaStreamTrack = typeof stream.stop === 'function' ? stream : stream.getTracks()[0];
                          var input = audio_context.createMediaStreamSource(stream);
                               __log('Media stream created.');

                              // Uncomment if you want the audio to feedback directly
                              input.connect(audio_context.destination);
                              __log('Input connected to audio context destination.');
                              
                              recorder = new Recorder(input);
                              openUserMedia=true;
                               __log('Recorder initialised.');
                        }, 
                        function (error) {
                          openUserMedia=false;
                          if(!init)
                            alert('请检查麦克风设备是否连接正常。异常信息:' + (error.code || error.name));
                                   
                        }
            );
                
    
  /*  navigator.getUserMedia({audio: true}, function(stream){
       
     });*/
  };




  function timeOut(){
          /*for(var  i=60;i>0;i--){*/
                  // time=1;
                  if(time<=60){
                          // var msg="验证码已发送"+i;
                          // document.all["Code_text"].innerHTML = msg;
                          ++time;
                  }

                  // $("#Code_text").innerHTML("验证码已发送"+i);
          /*}*/

  }