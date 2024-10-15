import java.util.Collections;  // para el shuffle
float rectsize = 1; // tamaño rectángulo scene 1
int countframe = 1;  // contador frames ref. cambio de escena 
int scene = 1;   
int speed = 2;  // velocidad genérica escenas
PImage imgAtlas1;  // carga imágenes scene 2
PImage imgAtlas2;
PImage imgAtlas3;
PImage backgroundImg;  // background para scene 2
PImage[] backgrounds = new PImage[4];  // array para cambios de background en scene 2
int currentBackground = 0;  // para cambios de background en scene 2
boolean isRectangle = true;  // forma del objeto en scene 1
PImage[] gridImages = new PImage[3];  // imágenes para scene 3
boolean[][] gridFilled;  // matriz para seguimiento del grid de scene 3
int numberOfColumns = 5;  // num. columnas grid scene 3
int numberOfRows = 5;  // num. filas grid scene 3
int nextCellIndex = 0;  // siguiente celda
int scene3Speed = 5; // velocidad imágenes scene 3
ArrayList<PVector> cellPositions;  // posición celdas en grid

void setup() {
  size(700, 700);  // scene 1 no optimizada para altas resoluciones, recomendado ratio 1:1 y resolución <=700  (depende del hardware...)
  imgAtlas1 = loadImage("atlas1.jpg");  // img scene 2
  imgAtlas2 = loadImage("atlas1.png");
  imgAtlas3 = loadImage("atlas3.png");
  backgrounds[0] = loadImage("C.jpg");  // img fondo scene 2
  backgrounds[1] = loadImage("M.jpg");
  backgrounds[2] = loadImage("Y.jpg");
  backgrounds[3] = loadImage("K.jpg");
  backgroundImg = backgrounds[currentBackground];
  gridImages[0] = loadImage("R.jpg");  // img grid scene 3
  gridImages[1] = loadImage("G.jpg");
  gridImages[2] = loadImage("B.jpg");
  noCursor();
  background(0);

  // iniciamos la matriz para el seguimiento del grid en scene 3
  gridFilled = new boolean[numberOfColumns][numberOfRows];
  cellPositions = new ArrayList<PVector>();
  float cellWidth = width / (float) numberOfColumns;
  float cellHeight = height / (float) numberOfRows;
  for (int column = 0; column < numberOfColumns; column = column + 1) {
    for (int row = 0; row < numberOfRows; row = row + 1) {
      cellPositions.add(new PVector(column * cellWidth + cellWidth / 2, row * cellHeight + cellHeight / 2));
      gridFilled[column][row] = false;
    }
  }
  Collections.shuffle(cellPositions);  // del import java.util.Collections para el shuffle
}

void draw() {
  if (scene == 1 || scene == 2) { 
    fill(0, 0, 0, 20); // para evitar que la escena se oscurezca demasiado
    noStroke();
    rect(0, 0, width, height); // rectángulo fondo
  }

  if (scene == 1) {  // SCENE 1: expansión de forma + strobe
    stroke(random(0), random(255), random(255), 175); // color stroke aleatorio dentro de paleta designada
    noFill();
    strokeWeight(2);
    filter(BLUR, 2);  // blur del objeto, recomendado <=2 (por optimización)
    rectsize = rectsize + speed;  // lógica tamaño objeto

    // el objeto se crea en el punto central y expande hasta el límite del canvas
    float centerX = width / 2;
    float centerY = height / 2;

    if (isRectangle) {
      square(centerX - rectsize / 2, centerY - rectsize / 2, rectsize);
    } else {
      ellipse(centerX, centerY, rectsize, rectsize);  // cambio de rectángulo a elipse
    }

    if (rectsize > max(width, height)) {
      rectsize = 1; // si llega a tamaño máximo, reset
    }
  }

  if (scene == 2) {  // SCENE 2: lámpara CMYK + strobe invertido
    
    image(backgroundImg, 0, 0, width, height);  // cambio background, con tinte sin color y con alpha para suavizar transición
    tint(255, 65);  
  }

  if (scene == 3) {  // SCENE 3: grid RGB generativo + strobe invertido
    int numberOfColumns = 5;  // data para scene 3
    int numberOfRows = 5;
    float cellWidth = width / (float) numberOfColumns;
    float cellHeight = height / (float) numberOfRows;
    if (frameCount % scene3Speed == 0 && nextCellIndex < cellPositions.size()) {  // condición siguiente img
      PVector currentPos = cellPositions.get(nextCellIndex);
      image(gridImages[(int) random(3)], currentPos.x - cellWidth / 2, currentPos.y - cellHeight / 2, cellWidth, cellHeight);
      nextCellIndex = nextCellIndex + 1;  // siguiente celda
    }
    if (nextCellIndex >= cellPositions.size()) {
      nextCellIndex = 0;
      Collections.shuffle(cellPositions); // reinicia y llamada al shuffle (aleatorio)
    }
  }
}

void keyPressed() {

  // CAMBIOS DE ESCENA, NUM 1, 2, 3

  if (key == '1') {
    scene = 1;
    background(0);
    rectsize = 1;
    countframe = 1;
  }
  if (key == '2') {
    scene = 2;
    background(0);
    rectsize = 1;
    countframe = 1;
  }
  if (key == '3') {
    scene = 3;
    background(0); 
    noTint(); // limpieza escena por tintes anteriores al cambiar a scene 3
    fill(0);
    rect(0, 0, width, height); // limpieza transparencias escenas anteriores + background rect. vacío
    nextCellIndex = 0;
    countframe = 1;
  }

  if (keyCode == UP) {  // flecha direccional ARRIBA
    if (scene == 1) {  // SCENE 1: (mantener pulsado) aumenta la velocidad
      speed += 2;  
    } else if (scene == 2) {  // SCENE 2: cambiamos fondo a M (magenta)
      currentBackground = 1;  
      backgroundImg = backgrounds[currentBackground];
    } else if (scene == 3) {  // SCENE 3: (mantener pulsado) aumenta la velocidad
      scene3Speed = max(1, scene3Speed - 1);  
    }
  }

  if (keyCode == DOWN) {  // flecha direccional ABAJO
    if (scene == 1) {  // SCENE 1: (mantener pulsado) reduce la velocidad
      speed = max(1, speed - 2);  
    } else if (scene == 2) {  // SCENE 2: cambiamos fondo a K (key-negro)
      currentBackground = 3;  
      backgroundImg = backgrounds[currentBackground];
    } else if (scene == 3) {  // SCENE 3: (mantener pulsado) reduce la velocidad
      scene3Speed = scene3Speed + 1;  
    }
  }

  if (keyCode == LEFT) {  // flecha direccional IZQUIERDA
    if (scene == 1) {  // SCENE 1: cambia la forma a rectángulo
      isRectangle = true;  
    } else if (scene == 2) {
      currentBackground = 0;  // SCENE2: cambiamos fondo a C (cyan)
      backgroundImg = backgrounds[currentBackground];
    } else if (scene == 3) {  // SCENE 3: filtro ERODE (reduce luminosidad)
      filter(ERODE);
    }
  }

  if (keyCode == RIGHT) {  // flecha direccional DERECHA
    if (scene == 1) {  // SCENE 1: cambia la forma a círculo
      isRectangle = false;  
    } else if (scene == 2) {  // SCENE2: cambiamos fondo a Y (yellow)
      currentBackground = 2;  
      backgroundImg = backgrounds[currentBackground];
    } else if (scene == 3) {  // SCENE 3: filtro DILATE (aumenta luminosidad)
      filter(DILATE);
    }
  }

  if (key == ' ') {  // BARRA ESPACIADORA
    if (scene == 1) {  // SCENE1: aleatoriza background (mantener pulsado para strobe)
      background(random(0), random(255), random(255), 175);  
    } else if (scene == 2) {  // SCENE 2: filtro INVERT (flash de colores invertidos, mantener pulsado para strobe)
      filter(INVERT);
      tint(255, 1);
    } else if (scene == 3) {  // SCENE 3: filtro INVERT (flash de colores invertidos, mantener pulsado para strobe)
      filter(INVERT);
    }
  }
}
