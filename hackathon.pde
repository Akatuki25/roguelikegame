import processing.data.*;

Table table;

int resX = 50; // マップの横マス数
int resY = 50; // マップの縦マス数
int tileSize = 15; // タイルのサイズ
int[][] map; // マップの2次元配列

ArrayList<Rect> rooms; // 部屋リスト
ArrayList<Rect> halls; // 通路リスト

//キャラ位置の定義
int playerX;
int playerY;

// キャラクターのステータス
int playerLevel = 1;
int playerHealth = 100;
int playerAttack = 10;
int playerMP = 100;
int playerCurrentMP = playerMP;

//階層
int stair = 1;

// スコア
int score = 0;

// 敵リスト
ArrayList<Enemy> enemies;

// 強敵リスト
ArrayList<StrongEnemy> strongenemies;
int bosssubjugation = 0;

// アイテムリスト
ArrayList<Item> items;

//シーン処理
int scene = 0;

//以下スキルの設定
// スキル１爆発の効果範囲、サイズ
float explosionRange = 50;
float explosionSize = 100;

//スキル２、回復量は下に

void setup() {

  size(1000, 750);

  map = new int[resY][resX];
  rooms = new ArrayList<Rect>();//全リスト初期化
  halls = new ArrayList<Rect>();
  enemies = new ArrayList<Enemy>();
  strongenemies = new ArrayList<StrongEnemy>();
  items = new ArrayList<Item>();

  generateDungeon();
}



void draw() {

  background(255);

if(scene==0){

fill(0);
strokeWeight(25);
textSize(50);
text("Click to start", width / 2 - 150, height / 2);

}else if (scene==1) {
  drawMap();
  keycheck();
  drawUI();

    for (Enemy enemy : enemies) {

    // 描画
    enemy.draw();

  }

  for (StrongEnemy strongenemy : strongenemies) {

    // 描画
    strongenemy.draw();

  }

   for (Item item : items) {

    // 描画
    item.draw();

  }
}else if (scene==2) {

  gameOver();

  displaySortedScores();

}

}

void mousePressed() {

  if (scene == 0) {

    scene = 1;

  }else if (scene == 2) {

    gamereset();

    scene = 1;
    
  }
}


// 敵のクラス定義
class Enemy {

  int x, y; // 敵の位置

  // 敵のステータス
  int health;
  int attack;

  Enemy(int x, int y) {

    this.x = x;
    this.y = y;
    this.health = 50*(1+(stair/10))*(1+((int)random(1, 3)/10)); // 初期ヘルス
    this.attack = 5*(1+stair/2); // 初期攻撃力
  }

  

//自機追従機能
  void chasePlayer() {

  // プレイヤーの位置
  int targetX = playerX;
  int targetY = playerY;

  // 距離を無限大に初期化
  int[][] distances = new int[resY][resX];

  for (int y = 0; y < resY; y++) {
    for (int x = 0; x < resX; x++) {

      distances[y][x] = Integer.MAX_VALUE;

    }
  }

  // 現在の敵の位置をスタート地点に設定
  distances[y][x] = 0;

  // 前の位置を記録する配列
  PVector[][] previous = new PVector[resY][resX];

  // まだ未訪問のセルを保持する2次元配列
  boolean[][] visited = new boolean[resY][resX];

  // 4方向の移動量
  int[] dx = {1, -1, 0, 0};
  int[] dy = {0, 0, 1, -1};

  while (true) {

    int shortestDist = Integer.MAX_VALUE;
    int bestX = -1;
    int bestY = -1;

    // 最小の距離を持つ未訪問のセルを探す
    for (int y = 0; y < resY; y++) {
      for (int x = 0; x < resX; x++) {

        if (!visited[y][x] && distances[y][x] < shortestDist) {

          shortestDist = distances[y][x];

          bestX = x;
          bestY = y;

        }
      }
    }

    // 最短距離のセルが見つからない場合、探索終了
    if (bestX == -1 || bestY == -1) {

      break;

    }

    // 最短距離のセルを訪問済みに設定
    visited[bestY][bestX] = true;

    // 4つの方向をチェック
    for (int i = 0; i < 4; i++) {

      int newX = bestX + dx[i];
      int newY = bestY + dy[i];

      // マップの端を超えないようにチェック
      if (newX >= 0 && newY >= 0 && newX < resX && newY < resY) {

        if (map[newY][newX] == 0) {  // 壁でない場合

          int newDist = shortestDist + 1;  // 現在の距離 + 移動コスト

          if (newDist < distances[newY][newX]) {

            distances[newY][newX] = newDist;

            previous[newY][newX] = new PVector(bestX, bestY);

          }
        }
      }
    }

    // プレイヤーの位置に到達した場合、探索終了
    if (bestX == targetX && bestY == targetY) {

      break;

    }
  }

  // プレイヤーへの経路が見つかった場合、新しい次の位置を設定
  PVector currentStep = new PVector(targetX, targetY);
  PVector nextStep = null;
  while (currentStep != null) {

    PVector prevStep = previous[(int)currentStep.y][(int)currentStep.x];

    if (prevStep != null && prevStep.x == x && prevStep.y == y) {

      nextStep = currentStep;

      break;

    }

    currentStep = prevStep;

  }

  if (nextStep != null) {

    x = (int)nextStep.x;
    y = (int)nextStep.y;

  }
}

  void draw() {

    strokeWeight(1);
    fill(0, 255, 0);
    rect(x * tileSize, y * tileSize, tileSize, tileSize);

  }
}

// 強敵のクラス定義
class StrongEnemy {

  int x, y; // 強敵の位置

  // 強敵のステータス
  int health;
  int attack;

  StrongEnemy(int x, int y) {

    this.x = x;
    this.y = y;
    this.health = 100*(1+(stair/5))*(1+((int)random(1, 3)/10)); // 初期ヘルス
    this.attack = 7*(1+(stair/2)); // 初期攻撃力
  }

  

//自機追従機能
  void chasePlayer() {

  // プレイヤーの位置
  int targetX = playerX;
  int targetY = playerY;

  // 距離を無限大に初期化
  int[][] distances = new int[resY][resX];

  for (int y = 0; y < resY; y++) {
    for (int x = 0; x < resX; x++) {

      distances[y][x] = Integer.MAX_VALUE;

    }
  }

  // 現在の敵の位置をスタート地点に設定
  distances[y][x] = 0;

  // 前の位置を記録する配列
  PVector[][] previous = new PVector[resY][resX];

  // まだ未訪問のセルを保持する2次元配列
  boolean[][] visited = new boolean[resY][resX];

  // 4方向の移動量
  int[] dx = {1, -1, 0, 0};
  int[] dy = {0, 0, 1, -1};

  while (true) {

    int shortestDist = Integer.MAX_VALUE;
    int bestX = -1;
    int bestY = -1;

    // 最小の距離を持つ未訪問のセルを探す
    for (int y = 0; y < resY; y++) {
      for (int x = 0; x < resX; x++) {

        if (!visited[y][x] && distances[y][x] < shortestDist) {

          shortestDist = distances[y][x];

          bestX = x;
          bestY = y;

        }
      }
    }

    // 最短距離のセルが見つからない場合、探索終了
    if (bestX == -1 || bestY == -1) {

      break;

    }

    // 最短距離のセルを訪問済みに設定
    visited[bestY][bestX] = true;

    // 4つの方向をチェック
    for (int i = 0; i < 4; i++) {

      int newX = bestX + dx[i];
      int newY = bestY + dy[i];

      // マップの端を超えないようにチェック
      if (newX >= 0 && newY >= 0 && newX < resX && newY < resY) {

        if (map[newY][newX] == 0) {  // 壁でない場合

          int newDist = shortestDist + 1;  // 現在の距離 + 移動コスト

          if (newDist < distances[newY][newX]) {

            distances[newY][newX] = newDist;

            previous[newY][newX] = new PVector(bestX, bestY);

          }
        }
      }
    }

    // プレイヤーの位置に到達した場合、探索終了
    if (bestX == targetX && bestY == targetY) {

      break;

    }
  }

  // プレイヤーへの経路が見つかった場合、新しい次の位置を設定
  PVector currentStep = new PVector(targetX, targetY);
  PVector nextStep = null;
  while (currentStep != null) {

    PVector prevStep = previous[(int)currentStep.y][(int)currentStep.x];

    if (prevStep != null && prevStep.x == x && prevStep.y == y) {

      nextStep = currentStep;

      break;

    }

    currentStep = prevStep;

  }

  if (nextStep != null) {

    x = (int)nextStep.x;
    y = (int)nextStep.y;

  }
}

  void draw() {

    strokeWeight(1);
    fill(255, 0, 255);
    rect(x * tileSize, y * tileSize, tileSize, tileSize);

  }
}

// アイテムのクラス定義
class Item {

  int x, y; // アイテムの位置

  // アイテムのステータス
  int health;
  int attack;
  int magicpoint;

  Item(int x, int y) {

    this.x = x;
    this.y = y;
    this.health = (int)random(-20, 20); // 回復量
    this.attack = (int)random(0, 5); // バフ攻撃力
    this.magicpoint = (int)random(8, 15);//回復MP
  }

  void draw() {

    strokeWeight(1);
    fill(255, 255, 0);
    rect(x * tileSize, y * tileSize, tileSize, tileSize);

  }



  int dist(int x1, int y1, int x2, int y2) {

    return abs(x1 - x2) + abs(y1 - y2);

  }
}



// プレイヤーの初期位置を決定
void spawnPlayer() {

  for (int i = 0; i < 10000000; i++) {

    playerX = (int) random(1, resX - 1); // マップ上のランダムなX座標
    playerY = (int) random(1, resY - 1); // マップ上のランダムなY座標

    if (map[playerY][playerX] == 0) {

      break; // 自機が配置されたらループを終了

    }
  }

  // 敵のスポーン
  spawnEnemies();
}



// 敵のスポーン
void spawnEnemies() {

  enemies.clear(); // 前のダンジョンの敵をクリア

  for (int i = 0; i < 5; i++) { // 5体の敵をスポーン

    for (int j = 0; j < 10000000; j++) {

      int enemyX = (int) random(1, resX - 1);
      int enemyY = (int) random(1, resY - 1);

      if (map[enemyY][enemyX] == 0 && (enemyX != playerX || enemyY != playerY)) {

        enemies.add(new Enemy(enemyX, enemyY));

        break;
      }
    }
  }

  spawnStrongEnemies();

  spawnitems();

}

void spawnStrongEnemies() {

  strongenemies.clear(); // 前のダンジョンの敵をクリア

    int spownnumber = 1;

  if(random(1)<0.05){
    spownnumber = 2; //５％の確率で強敵２体
  }

  for(int s = 0; s < spownnumber; s++){
    for (int j = 0; j < 10000000; j++) {

      int strongenemyX = (int) random(1, resX - 1);
      int strongenemyY = (int) random(1, resY - 1);

      if (map[strongenemyY][strongenemyX] == 0 && (strongenemyX != playerX || strongenemyY != playerY)) {

        strongenemies.add(new StrongEnemy(strongenemyX, strongenemyY));

        break;
      }
    }
  }
}

//アイテムのスポーン
void spawnitems() {

  items.clear(); // 前のダンジョンのアイテムをクリア

  int spownnumber = 1;

//低確率でアイテム量を２、３倍に
  if(random(1) < 0.01){
    spownnumber = 3;
  }else if(random(1) < 0.06){
    spownnumber = 2;
  }

for(int s = 0; s < spownnumber; s++){
  for (int i = 0; i < (int)random(3, 5); i++) { // 3-5個のアイテムをスポーン

    for (int j = 0; j < 10000000; j++) {

      int itemX = (int) random(1, resX - 1);
      int itemY = (int) random(1, resY - 1);

      if (map[itemY][itemX] == 0 && (itemX != playerX || itemY != playerY)) {

        items.add(new Item(itemX, itemY));

        break;
      }
    }
  }
}
}



// 移動を検知
void keycheck() {

  if (keyPressed == true) {
    frameRate(15);
    if (key == 'w') {

      movePlayer(0, -1);

    } else if (key == 's') {

      movePlayer(0, 1);

    } else if (key == 'a') {

      movePlayer(-1, 0);

    } else if (key == 'd') {

      movePlayer(1, 0);

    }
  }
}


void keyPressed(){
  if(key==CODED){
    frameRate(5);
    if(keyCode==UP){

      movePlayer(0, -1);
      
    }else if (keyCode==DOWN) {

      movePlayer(0, 1);
      
    }else if (keyCode==LEFT) {

      movePlayer(-1, 0);
      
    }else if (keyCode==RIGHT) {

      movePlayer(1, 0);
      
    }
  }
  if (key == '1') {
    useSkill1(); // 1を押すとスキル1を使用する
  }
  if (key == '2') {
    useSkill2(); // 2を押すとスキル2を使用する
  }
  if (key == '3') {
    useSkill3(); // 3を押すとスキル3を使用する
  }
  if (key == ' ') {
    useSkillblank(); // 空白を押すと隠しスキルを使用する
  }
}



// プレイヤーの移動
void movePlayer(int dx, int dy) {

  int newX = playerX + dx;
  int newY = playerY + dy;

  if (map[newY][newX] == 1) {

    return;

  }

  playerX = newX;
  playerY = newY;

  for (Enemy enemy : enemies) {

    // 敵の追跡動作
   enemy.chasePlayer();

  }

   for (StrongEnemy strongenemy : strongenemies) {

    // 強敵の追跡動作
   strongenemy.chasePlayer();

  }

  checkCollisions();

  if (score >= (playerLevel * 2 - 1) * 100) {

    playerLevel++;
    playerAttack += 5;
    playerHealth = 100 + 5*bosssubjugation;

  }

    if (playerHealth <= 0) {

        saveScore(score);

        scene = 2; // プレイヤーの体力が0以下になったらゲームオーバー

        }

  if (map[newY][newX] == 2) {

    score += 50;

    stair++;

    changestairs();

  }
}

// UIの設定
void drawUI() {

  strokeWeight(1);
  stroke(128);
  fill(128, 128, 128);
  rect(750, 0, 250, 750);
  fill(0);
  textSize(25);
  text("Level: " + playerLevel, 800, 30);
  text("HP: " + playerHealth, 800, 50);
  text("MP: " + playerCurrentMP, 800, 95);
  text("Attack: " + playerAttack, 800, 150);
  text("Nextlevel: " + ((playerLevel * 2 - 1) * 100 - score), 800, 170);
  text("Score: " + score, 800, 190);
  text("Floor: " + stair, 800, 210);
  text("You", 800, 265);
  text("Stair", 800, 285);
  text("Enemy", 800, 305);
  text("BossEnemy", 800, 325);
  text("Item", 800, 345);
  text("Skill: Press number", 780, 385);
  text("1: Explosion", 780, 405);
  text("2: Heal", 780, 425);
  text("3: Randomwarp", 780, 445);
  text("   : ???", 780, 465);
  
  strokeWeight(1);
  fill(255, 0, 0);
  rect(780, 250, tileSize, tileSize);

  fill(0, 0, 255);
  rect(780, 270, tileSize, tileSize);

  fill(0, 255, 0);
  rect(780, 290, tileSize, tileSize);

  fill(255, 0, 255);
  rect(780, 310, tileSize, tileSize);

  fill(255, 255, 0);
  rect(780, 330, tileSize, tileSize);
  /*text("通常上下左右移動: WASD" , 800, 230);
  text("低速上下左右移動: 方向キー" , 800, 250);
  text("スキル１: プレイヤーを中心に爆発を起こし敵にダメージを与える" , 800, 270);
  text("スキル２: プレイヤーの体力を回復する" , 800, 310);
  text("キー１  消費MP: 40" , 800, 290);
  text("キー２  消費MP: 20" , 800, 330);*/

if(playerHealth <= 200){

  strokeWeight(1);
  fill(255, 0, 0);
  rect(780, 50, 100 + bosssubjugation * 5, 20);

  strokeWeight(1);
  fill(0, 255, 0);
  rect(780, 50, playerHealth, 20);

}else if (playerHealth <= 400) {

  strokeWeight(1);
  fill(0, 255, 0);
  rect(780, 50, 200, 20);

  strokeWeight(1);
  fill(0, 255, 0);
  rect(780, 53, playerHealth - 200, 20);
  
}

if(playerCurrentMP <= 200){
  fill(0);
  rect(780, 95, 100, 20);

  fill(0, 255, 0);
  rect(780, 95, playerCurrentMP, 20);
}else if (playerCurrentMP <= 400) {

  fill(0, 255, 0);
  rect(780, 95, 200, 20);

   fill(0, 255, 0);
  rect(780, 98, playerCurrentMP - 200, 20);
  
}else if(playerCurrentMP <= 600) {

  fill(0, 255, 0);
  rect(780, 95, 200, 20);

   fill(0, 255, 0);
  rect(780, 98, 200, 20);

  fill(0, 255, 0);
  rect(780, 101, playerCurrentMP - 400, 20);
  
}else {

  fill(0, 255, 0);
  rect(780, 95, 200, 20);

   fill(0, 255, 0);
  rect(780, 98, 200, 20);

  fill(0, 255, 0);
  rect(780, 101, 200, 20);

    fill(0, 255, 0);
  rect(780, 104, playerCurrentMP - 600, 20);
  
}

}


//階層変化処理
void changestairs() {

  if (random(1) < 0.4) {
    rooms = new ArrayList<Rect>();
    halls = new ArrayList<Rect>();
  }

  generateDungeon();

}

//ここからダンジョン生成アルゴリズム
void generateDungeon() {
  initializeMap();
  fillMapWithWalls();
  Rect initialRoom = new Rect(1, 1, resX - 2, resY - 2);
  subdivideRoom(initialRoom);
  makeRooms();
  connectRooms();

}


//マップを黒埋め
void initializeMap() {

  for (int y = 0; y < resY; y++) {

    for (int x = 0; x < resX; x++) {

      map[y][x] = 1;

    }

  }

}


//画面端を壁にする
void fillMapWithWalls() {

  for (int y = 0; y < resY; y++) {

    for (int x = 0; x < resX; x++) {

      map[y][x] = 1;

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

  PVector center() {

    return new PVector(x + w / 2, y + h / 2);

  }

  boolean intersects(Rect other) {

    return x < other.x + other.w && x + w > other.x &&
           y < other.y + other.h && y + h > other.y;

  }

}


//区画を分割する
void subdivideRoom(Rect room) {

  if (room.w > 14 && room.h > 14) {

    boolean splitHorizontally = random(1) > 0.5;

    if (splitHorizontally) {

      int splitY = room.y + (int) random(3, room.h - 3);

      Rect top = new Rect(room.x, room.y, room.w, splitY - room.y);
      Rect bottom = new Rect(room.x, splitY, room.w, room.h - (splitY - room.y));

      subdivideRoom(top);

      subdivideRoom(bottom);

    } else {

      int splitX = room.x + (int) random(3, room.w - 3);

      Rect left = new Rect(room.x, room.y, splitX - room.x, room.h);
      Rect right = new Rect(splitX, room.y, room.w - (splitX - room.x), room.h);

      subdivideRoom(left);

      subdivideRoom(right);

    }

  } else {

    rooms.add(room);

  }

}


//区画に基づき部屋を作る
void makeRooms() {

  ArrayList<Rect> newRooms = new ArrayList<Rect>();


  for (Rect room : rooms) {

    int roomX = room.x + (int) random(1, room.w / 3);
    int roomY = room.y + (int) random(1, room.h / 3);
    int roomW = room.w - (roomX - room.x) - (int) random(1, room.w / 3);
    int roomH = room.h - (roomY - room.y) - (int) random(1, room.h / 3);


    Rect newRoom = new Rect(roomX, roomY, roomW, roomH);

    boolean overlap = false;

    for (Rect otherRoom : newRooms) {

      if (newRoom.intersects(otherRoom)) {

        overlap = true;

        break;

      }

    }

    if (!overlap) {

      newRooms.add(newRoom);

      for (int y = roomY; y < roomY + roomH; y++) {
        for (int x = roomX; x < roomX + roomW; x++) {

          map[y][x] = 0;

        }
      }
    }
  }

  rooms = newRooms;

}


//部屋をつなぐ
void connectRooms() {

  spawnPlayer();

  for (int i = 0; i < rooms.size() - 1; i++) {

    Rect roomA = rooms.get(i);
    Rect roomB = rooms.get(i + 1);

    PVector pointA = roomA.center();
    PVector pointB = roomB.center();

    while (pointA.x != pointB.x) {

      map[(int) pointA.y][(int) pointA.x] = 0;

      pointA.x += (pointB.x - pointA.x) / abs(pointB.x - pointA.x);

    }

    while (pointA.y != pointB.y) {

      map[(int) pointA.y][(int) pointA.x] = 0;

      pointA.y += (pointB.y - pointA.y) / abs(pointB.y - pointA.y);

    }

    halls.add(new Rect((int) min(pointA.x, pointB.x), (int) min(pointA.y, pointB.y), (int) abs(pointA.x - pointB.x), (int) abs(pointA.y - pointB.y)));

  }

  generateStairs();

}


//階段生成
void generateStairs() {

  for (int i = 0; i < 100000000; i++) {

    int stairX = (int) random(1, resX - 1);
    int stairY = (int) random(1, resY - 1);

if (map[stairY][stairX] == 0 && map[stairY][stairX] != 2) {

      map[stairY][stairX] = 2; // 階段を配置
      break; // 階段が配置されたらループを終了

    }
  }
}

// マップを描画
void drawMap() {

  for (int y = 0; y < resY; y++) {
    for (int x = 0; x < resX; x++) {
      if (map[y][x] == 1) {

        fill(0); // 壁: 黒色

      } else if(map[y][x] == 0){

        fill(255); // 床: 白色

      } else if(map[y][x] == 2){

        fill(0, 0, 255); // 階段: 青色

      }

      if(y == playerY && x == playerX){

        fill(255, 0, 0);// 自機: 赤色

      }

      strokeWeight(1);
      rect(x * tileSize, y * tileSize, tileSize, tileSize);

    }
  }
}
//ここまで



// プレイヤーと敵の衝突判定
void checkCollisions() {

  for(Item item : items) {
    if (playerX == item.x && playerY == item.y){

      //アイテムとの接触処理
      playerAttack += item.attack;
      playerHealth += item.health;
      playerCurrentMP += item.magicpoint;


      items.remove(item);

      break;

    }
  }

  for (Enemy enemy : enemies) {
    if (playerX == enemy.x && playerY == enemy.y) {

      // 敵との戦闘処理
      playerHealth -= enemy.attack;
      enemy.health -= playerAttack;

      if (enemy.health <= 0) {

        enemies.remove(enemy);

        score += 25;

        break;

      }
    }
  }

  for (StrongEnemy strongenemy : strongenemies) {
    if (playerX == strongenemy.x && playerY == strongenemy.y) {

      // 強敵との戦闘処理
      playerHealth -= strongenemy.attack;
      strongenemy.health -= playerAttack;

      if (strongenemy.health <= 0) {

        strongenemies.remove(strongenemy);

        score += 100;
        bosssubjugation++;

        break;

      }
    }
  }
}



// ゲームオーバー処理
void gameOver() {

  fill(255, 0, 0);
  textSize(50);
  strokeWeight(5);
  text("Game Over", width / 2 - 200, height / 2 - 150);
  text("SCORE: " + score, width / 2 - 200, height / 2 - 50);
  text("Floor: " + stair, width / 2 - 200, height / 2 + 50);
  text("Click to restart", width / 2 - 200, height / 2 + 150);

}


void gamereset() {

  // キャラクターのステータス
playerLevel = 1;
playerHealth = 100;
playerAttack = 10;
playerCurrentMP = 100;

//階層
stair = 1;

// スコア
score = 0;

//討伐数リセット
bosssubjugation = 0;

 rooms = new ArrayList<Rect>();//全リスト初期化
  halls = new ArrayList<Rect>();
  enemies = new ArrayList<Enemy>();
  strongenemies = new ArrayList<StrongEnemy>();
  items = new ArrayList<Item>();

  generateDungeon();

}



//以下スキル設定
//スキル1　イオ的な何か
void useSkill1() {
  // プレイヤーのMPを確認してスキルを使う
  if (playerCurrentMP >= 40) { // スキルの使用に必要なMPを設定
    // スキルの効果を適用

    // 爆発のエフェクトを描画
    drawskill1(playerX, playerY);

    for (Enemy enemy : enemies) {
      float distance = dist(playerX*tileSize, playerY*tileSize, enemy.x*tileSize, enemy.y*tileSize); // プレイヤーと敵の距離を計算
      if (distance <= explosionRange) { // 爆発の範囲内にいる敵にダメージを与える

        enemy.health -= 40 + (playerAttack*1.1); // スキルダメージ計算式

      }
      if (enemy.health <= 0) {

        enemies.remove(enemy);

        score += 25;

        break;

      }

      enemy.chasePlayer();

    }

    for (StrongEnemy strongenemy : strongenemies) {
      float distance = dist(playerX*tileSize, playerY*tileSize, strongenemy.x*tileSize, strongenemy.y*tileSize); // プレイヤーと敵の距離を計算
      if (distance-10 <= explosionRange) { // 爆発の範囲内にいる敵にダメージを与える

        strongenemy.health -= 40 + (playerAttack*1.1); // スキルの効果を固定値 + 攻撃力＊1.1で設定
        
      }
      if (strongenemy.health <= 0) {

        strongenemies.remove(strongenemy);

        score += 100;
        bosssubjugation++;

        break;

      }

      strongenemy.chasePlayer();

    }

      checkCollisions();

    if (score >= (playerLevel * 2 - 1) * 100) {

    playerLevel++;
    playerAttack += 5;
    playerHealth = 100 + 5*bosssubjugation;

  }

 if (playerHealth <= 0) {

     saveScore(score);

    scene = 2; // プレイヤーの体力が0以下になったらゲームオーバー

 }

    // スキルを使用したらMPを消費
    playerCurrentMP -= 40; // スキルの使用に必要なMPを消費
    
  }
}

void drawskill1(float x, float y) {
  noStroke();
  fill(255, 0, 0, 150); // 赤色の半透明の塗りつぶし
  ellipse(x*tileSize, y*tileSize, explosionSize, explosionSize); // 中心点が(x, y)の円を描画
}

//スキル2ホイミ的な何か
void useSkill2() {
 int healpoint = 30 + playerLevel;
 if (playerCurrentMP >= 8) { // スキルの使用に必要なMPを設定

    // スキルの効果を適用
    playerHealth += healpoint;
    if(playerHealth >= 100 + (5 * bosssubjugation)){
      playerHealth = 100 + (5 * bosssubjugation);
    }

    for (Enemy enemy : enemies) {

     enemy.chasePlayer();

    }

    for (StrongEnemy strongenemy : strongenemies) {
      
     strongenemy.chasePlayer();

      }

     checkCollisions();

     if(playerHealth <= 0){

      saveScore(score);

      scene = 2;

     }

    // スキルを使用したらMPを消費
    playerCurrentMP -= 8; // スキルの使用に必要なMPを消費
    
  }
}

//ワープするだけ
void useSkill3() {
 if (playerCurrentMP >= 10) { // スキルの使用に必要なMPを設定

    // スキルの効果を適用
    for (int i = 0; i < 10000000; i++) {

    playerX = (int) random(1, resX - 1); // マップ上のランダムなX座標
    playerY = (int) random(1, resY - 1); // マップ上のランダムなY座標

    if (map[playerY][playerX] == 0) {

      break; // 自機が配置されたらループを終了

    }
  }

    for (Enemy enemy : enemies) {

      enemy.chasePlayer();

    }

    for (StrongEnemy strongenemy : strongenemies) {
      
         strongenemy.chasePlayer();

      }

     checkCollisions();

     if(playerHealth <= 0){

       saveScore(score);

      scene = 2;

     }

    // スキルを使用したらMPを消費
    playerCurrentMP -= 10; // スキルの使用に必要なMPを消費
    
  }
}

//一応隠し　マダンテ想定
void useSkillblank() {
  // プレイヤーのMPを確認してスキルを使う
  if (playerCurrentMP >= 80) { // スキルの使用に必要なMPを設定
    // スキルの効果を適用

        // 爆発のエフェクトを描画
    drawskillblank(playerX, playerY);

for(int s = 0; s < 5; s++){
    for (Enemy enemy : enemies) {

      enemy.health -= 250 + (playerCurrentMP*5); // スキルの効果を固定値 + 攻撃力＊1.1で設定
        
      if (enemy.health <= 0) {

        enemies.remove(enemy);

        score += 25;

        break;

      }

      enemy.chasePlayer();

    }

    for (StrongEnemy strongenemy : strongenemies) {

        strongenemy.health -= 250 + (playerCurrentMP*5); // スキルの効果を固定値 + 攻撃力＊1.1で設定
        
      if (strongenemy.health <= 0) {

        strongenemies.remove(strongenemy);

        score += 100;
        bosssubjugation++;

        break;

      }

      strongenemy.chasePlayer();

    }
}

    checkCollisions();

    if (score >= (playerLevel * 2 - 1) * 100) {

    playerLevel++;
    playerAttack += 5;
    playerHealth = 100 + 5*bosssubjugation;

  }

 if (playerHealth <= 0) {

     saveScore(score);

    scene = 2;

 }

    playerCurrentMP = 0;
    
  }
}

void drawskillblank(float x, float y) {
  noStroke();
  fill(255, 0, 255, 100);
  ellipse(x*tileSize, y*tileSize, 1200, 1200);
}

void saveScore(int score) {

  TableRow newRow;

  if (table == null) {

    table = new Table();
    table.addColumn("Score");
    newRow = table.addRow();
    newRow.setInt("Score", score);

  } else {

    newRow = table.addRow();
    newRow.setInt("Score", score);

  }

  saveTable(table, "scores.csv");

}

void displaySortedScores() {

  table = loadTable("scores.csv", "header");

  TableRow[] rows = new TableRow[table.getRowCount()];

  for (int i = 0; i < table.getRowCount(); i++) {

    rows[i] = table.getRow(i);

  }

  // スコアの降順にソート
  rows = sort(rows);

  // ランキングを表示
  fill(0);
  textSize(50);
  text("Ranking:", 700, 450);

  for (int i = 0; i < min(rows.length, 5); i++) {  // Top 10を表示

    TableRow row = rows[i];

    int score = row.getInt("Score");

    text((i + 1) +": " + score, 700, 490 + i * 40);

  }
}

TableRow[] sort(TableRow[] rows) {

  // バブルソートを使用
  for (int i = 0; i < rows.length - 1; i++) {
    for (int j = 0; j < rows.length - 1 - i; j++) {
      if (rows[j].getInt("Score") < rows[j + 1].getInt("Score")) {

        TableRow temp = rows[j];

        rows[j] = rows[j + 1];
        rows[j + 1] = temp;

      }
    }
  }

  return rows;

}