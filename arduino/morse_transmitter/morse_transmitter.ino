// C++ code
#define led 11
#define buzzer A1
 String input="";
char flag=0;
void setup()
{
  pinMode(led,OUTPUT);
  pinMode(buzzer,OUTPUT);
  Serial.begin(9600);
}
void dot(){
  digitalWrite(led,HIGH);
  tone(buzzer,500);
  delay(300);
  digitalWrite(led,LOW);
  noTone(buzzer);
  delay(300);
}
void dash(){
  digitalWrite(led,HIGH);
  tone(buzzer,500);
  delay(900);
  digitalWrite(led,LOW);
  noTone(buzzer);
  delay(900);
}
void morse(char c){
  switch(tolower(c)){
      case 'a':
      dot();
      dash();
      break;
      case 'b':
      dash();
      dot();
      dot();
      dot();
      break;
      case 'c':
      dash();
      dot();
      dash();
      dot();
      break;
      case 'd':
      dash();
      dot();
      dot();
      break;
      case 'e':
      dot();
      
      break;
      case 'f':
      dot();
      dot();
      dash();
      dot();
      break;
      case 'g':
      dash();
      dash();
      dot();
      break;
      case 'h':
      dot();
      dot();
      dot();
      dot();
      break;
      case 'i':
      dot();
      dot();
      break;
      case 'j':
      dot();
      dash();
      dash();
      dash();
      break;
      case 'k':
     dash();
      dot();
      dash();
      break;
      case 'l':
      dot();
      dash();
      dot();
      dot();
      break;
      case 'm':
      dash();
      dash();
      break;
      case 'n':
      dash();
      dot();
      break;
      case 'o':
      dash();
      dash();
      dash();
      break;
      case 'p':
      dot();
      dash();
      dash();
      dot();
      break;
      case 'q':
      dash();
      dash();
      dot();
      dash();
      break;
      case 'r':
      dot();
      dash();
      dot();
      break;
      case 's':
      dot();
      dot();
      dot();
      break;
      case 't':
      dash();
      break;
      case 'u':
      dot();
      dot();
      dash();
      break;
      case 'v':
      dot();
      dot();
      dot();
      dash();
      break;
      case 'w':
      dot();
      dash();
      dash();
      break;
      case 'x':
      dash();
      dot();
      dot();
      dash();
      break;
      case 'y':
      dash();
      dot();
      dash();
      dash();
      break;
      case 'z':
      dash();
      dash();
      dot();
       dot();
      break;
      case '0':
      dash();
      dash();
      dash();
      dash();
      dash();
      break;
      case '1':
       dot();
      dash();
      dash();
      dash();
      dash();
      break;
      case '2':
      dot();
      dot();
      dash();
      dash();
      dash();
      break;
      case '3':
      dot();
      dot();
      dot();
      dash();
      dash();
      break;
      case '4':
      dot();
      dot();
      dot();
      dot();
      dash();
      break;
      case '5':
      dot();
      dot();
      dot();
      dot();
      dot();
      break;
      case '6':
      dash();
       dot();
       dot();
       dot();
       dot();
      break;
      case '7':
       dash();
       dash();
       dot();
       dot();
       dot();
      break;
      case '8':
       dash();
       dash();
       dash();
       dot();
       dot();
      break;
      case '9':
     dash();
       dash();
       dash();
       dash();
       dot();
      break;
      
    }
}

void loop()
{
  if(Serial.available()>0){
    input = Serial.readString();
    Serial.print("You typed: ");
    Serial.println(input);
    for(int i=0;i<input.length();i++){
      if(input[i]==' '||input[i]=='\n'||input[i]=='\r' ){
        if (flag==0){
        delay(2100);
        flag =1;
        }
      }
      else{
      Serial.print("the current letter: ");
      Serial.println(input[i]);
        
      morse(input[i]);
      delay(900);
        flag=0;
      }
    }
    
  }
}