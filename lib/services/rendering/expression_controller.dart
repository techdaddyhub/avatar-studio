enum AvatarExpression { neutral, smile, surprise, wink, thoughtful, laugh }

class ExpressionValues {
  final double smile;
  final double browRaise;
  final double leftBlink;
  final double rightBlink;
  final double mouthOpen;
  final double pitch;
  final double roll;

  const ExpressionValues({
    this.smile = 0.0,
    this.browRaise = 0.0,
    this.leftBlink = 0.0,
    this.rightBlink = 0.0,
    this.mouthOpen = 0.0,
    this.pitch = 0.0,
    this.roll = 0.0,
  });

  static const ExpressionValues neutral = ExpressionValues();

  static const ExpressionValues smileValues = ExpressionValues(
    smile: 0.85,
    browRaise: 0.2,
    mouthOpen: 0.15,
  );

  static const ExpressionValues surpriseValues = ExpressionValues(
    browRaise: 0.95,
    mouthOpen: 0.75,
    pitch: -0.1,
  );

  static const ExpressionValues winkValues = ExpressionValues(
    leftBlink: 1.0,
    rightBlink: 0.0,
    smile: 0.6,
    roll: 0.1,
  );

  static const ExpressionValues thoughtfulValues = ExpressionValues(
    browRaise: 0.4,
    smile: -0.1,
    pitch: 0.15,
    roll: -0.15,
  );

  static const ExpressionValues laughValues = ExpressionValues(
    smile: 1.0,
    browRaise: 0.5,
    leftBlink: 0.6,
    rightBlink: 0.6,
    mouthOpen: 0.85,
  );

  static ExpressionValues getValues(AvatarExpression expression) {
    switch (expression) {
      case AvatarExpression.neutral:
        return neutral;
      case AvatarExpression.smile:
        return smileValues;
      case AvatarExpression.surprise:
        return surpriseValues;
      case AvatarExpression.wink:
        return winkValues;
      case AvatarExpression.thoughtful:
        return thoughtfulValues;
      case AvatarExpression.laugh:
        return laughValues;
    }
  }
}
