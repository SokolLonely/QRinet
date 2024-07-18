class Mystopwatch
{ DateTime startTime = DateTime.now();
  var timeDifference = Duration.zero;//DateTime.now().difference(startTime);
  bool is_running = false;
  void start(){
    is_running = true;
    startTime = DateTime.now();
    print('start');
  }
  void stop(){
    is_running = false;
    print('stop');
  }
  void reset(){
    timeDifference = Duration.zero;
    startTime = DateTime.now();

  }
  Duration result(){
    if (is_running)
      {
        timeDifference = DateTime.now().difference(startTime);
      }
    return timeDifference;


  }
  bool isRunning(){
    return is_running;
  }
}