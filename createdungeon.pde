/*ダンジョン生成アルゴリズムの原型*/

int resX = 80; // マップの横サイズ

int resY = 80; // マップの縦サイズ

int tileSize = 10; // 各タイルのサイズ

int[][] map; // マップの2次元配列



void setup() {

  size(800, 800);

  map = new int[resY][resX];

  // 初期化: 2次元配列作成・区画リスト作成
  initializeMap();

  // すべてを壁にする
  fillMapWithWalls();

  // マップサイズで最初の区画を作る
  Rect initialRoom = new Rect(1, 1, resX - 2, resY - 2);

  // 区画を分割していく
  subdivideRoom(initialRoom);

  // 区画内に部屋を作る
  makeRooms(); 

  // 部屋同士をつなげる通路を作る
  connectRooms();

  // マップを描画
  drawMap();

}

void draw() {

}

// 初期化
void initializeMap() {

  for (int y = 0; y < resY; y++) {
    for (int x = 0; x < resX; x++) {

      map[y][x] = 1; // 全てを壁にする

    }
  }
}

// すべてを壁にする
void fillMapWithWalls() {

  for (int y = 0; y < resY; y++) {
    for (int x = 0; x < resX; x++) {

      map[y][x] = 1; // 壁

    }
  }
}

class Rect {

  int x, y, w, h;

  Rect(int ix, int iy, int iw, int ih) {

    x = ix;
    y = iy;
    w = iw;
    h = ih;

  }
}

ArrayList<Rect> rooms = new ArrayList<Rect>();

// 区画を分割していく
void subdivideRoom(Rect room) {

  if (room.w > 7 && room.h > 7) { // 基本的な大きさチェック

    rooms.add(room);

    // 分割条件と方向
    boolean splitHorizontally = random(1) > 0.5;

    if (splitHorizontally) {

      int splitY = room.y + (int)random(3, room.h - 3);
      Rect top = new Rect(room.x, room.y, room.w, splitY - room.y);
      Rect bottom = new Rect(room.x, splitY, room.w, room.h - (splitY - room.y));

      subdivideRoom(top);
      subdivideRoom(bottom);

    } else {

      int splitX = room.x + (int)random(3, room.w - 3);

      Rect left = new Rect(room.x, room.y, splitX - room.x, room.h);
      Rect right = new Rect(splitX, room.y, room.w - (splitX - room.x), room.h);

      subdivideRoom(left);
      subdivideRoom(right);

    }
  }
}



// 区画内に部屋を作る
void makeRooms() {

  for (Rect room : rooms) {

    int roomX = room.x + (int)random(1, room.w / 3);
    int roomY = room.y + (int)random(1, room.h / 3);
    int roomW = room.w - (roomX - room.x) - (int)random(1, room.w / 3);
    int roomH = room.h - (roomY - room.y) - (int)random(1, room.h / 3);

    

    for (int y = roomY; y < roomY + roomH; y++) {
      for (int x = roomX; x < roomX + roomW; x++) {

        map[y][x] = 0; // 床

      }

    }
  }
}

// 部屋同士をつなげる通路を作る
void connectRooms() {

  for (int i = 0; i < rooms.size() - 1; i++) {

    Rect roomA = rooms.get(i);
    Rect roomB = rooms.get(i + 1);

    int pointAX = (roomA.x + roomA.x + roomA.w) / 2;
    int pointAY = (roomA.y + roomA.y + roomA.h) / 2;
    int pointBX = (roomB.x + roomB.x + roomB.w) / 2;
    int pointBY = (roomB.y + roomB.y + roomB.h) / 2;  

    while (pointAX != pointBX) {

      map[pointAY][pointAX] = 0;

      pointAX += (pointBX - pointAX) / abs(pointBX - pointAX);

    }

    while (pointAY != pointBY) {

      map[pointAY][pointAX] = 0;

      pointAY += (pointBY - pointAY) / abs(pointBY - pointAY);

    }
  }
}

// マップを描画
void drawMap() {

  for (int y = 0; y < resY; y++) {
    for (int x = 0; x < resX; x++) {
      if (map[y][x] == 1) {

        fill(0); // 壁: 黒色

      } else {

        fill(255); // 床: 白色

      }

      rect(x * tileSize, y * tileSize, tileSize, tileSize);

    }
  }
}
