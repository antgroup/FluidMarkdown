// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { IStyled, IStyledOption, IStyledBuild, StyledSpan, StyledImageSpan, StyledMathSpan } from './styled';
import { StyledObject, EStyledObjectEvent, IStyledObjectAttachEvent, IStyledObjectReplaceStyleEvent, EStyledObjectMark } from './styled-object';
import { StyledEmbed, EStyledEmbedBuilder, StyledEmbedController } from './styled-embed';
import {
  StyledBaselineOffsetValue,
  StyledDecorationValue,
  StyledGestureValue,
  StyledLetterSpacingValue,
  StyledLineHeightValue,
  StyledParagraphValue,
  StyledTextValue,
  StyledBackgroundColorValue,
} from './styled-value';
import {
  Node, ENode, ELayout, EListItem,
  Document, Heading, LineBreak, Link,
  FootnoteRef, Code, ListItem, Emoji,
  HtmlTag, Image, Math as MathNode,
  StyledContent, List, Fragment,
} from '../../service/ast/node';
import { drawing } from '@kit.ArkGraphics2D';
import { HeadingLevelStyling } from '../../theme';
import { MDLength, newLog, MDColor } from '../../util';
import { LengthMetrics, Rect } from '@kit.ArkUI';
import OhosGText from '@ohos.graphics.text';
import type { IImageServiceRequest } from '../../service/image';

const log = newLog('Styled');

export abstract class Styled implements IStyled {
  readonly option: IStyledOption;
  constructor(option: IStyledOption) {
    this.option = option;
  }
  abstract get node(): Node | undefined;
  build(option: IStyledBuild): void {
    do {
      const anchor = StyledObject.begin({ styled: this }, undefined, EStyledObjectMark.BuildBegin);
      option.didCreateStyled(anchor);
      option.willBuild?.(anchor);
    } while (0);
    if (this.node?.layout === ELayout.Block) {
      option.didCreateStyled(StyledObject.begin({ styled: this }));
    }
    const hook = option.engine.render?.styledBuildingPlugin(this, option);
    if (hook) {
      hook.handler.building(this, option);
    } else {
      this.building(option);
    }
    if (this.node?.layout === ELayout.Block) {
      this.break(option);
      option.didCreateStyled(StyledObject.end({ styled: this }));
    }
    do {
      const anchor = StyledObject.end({ styled: this }, undefined, EStyledObjectMark.BuildEnd);
      option.didCreateStyled(anchor);
      option.didBuild?.(anchor);
    } while (0);
  }
  protected abstract building(option: IStyledBuild): void;
  private break(option: IStyledBuild) {
    if (!this.node?.hidden && this.node?.next) {
      const types = [
        ENode.Paragraph, ENode.Heading,
        ENode.Quote, ENode.ListItem, ENode.List,
        ENode.Code, ENode.Table,
      ];
      if (types.indexOf(this.node?.type) !== -1) {
        option.didCreateStyled(StyledObject.break({ styled: this }));
      }
    }
  }
  static create(option: IStyledOption): Styled | undefined {
    if (option.node?.is(ENode.Fragment)) {
      return new FragmentStyled(option);
    } else if (option.node?.is(ENode.Document)) {
      return new DocumentStyled(option);
    } else if (option.node?.is(ENode.Paragraph)) {
      return new ParagraphStyled(option);
    } else if (option.node?.is(ENode.ThematicBreak)) {
      return new ThematicBreakStyled(option);
    } else if (option.node?.is(ENode.Heading)) {
      return new HeadingStyled(option);
    } else if (option.node?.is(ENode.Quote)) {
      return new QuoteStyled(option);
    } else if (option.node?.is(ENode.Code)) {
      return new CodeStyled(option);
    } else if (option.node?.is(ENode.Table)) {
      return new TableStyled(option);
    } else if (option.node?.is(ENode.TableItem)) {
      return new TableItemStyled(option);
    } else if (option.node?.is(ENode.List)) {
      return new ListStyled(option);
    } else if (option.node?.is(ENode.ListItem)) {
      return new ListItemStyled(option);
    } else if (option.node?.is(ENode.HtmlTag)) {
      return new HtmlTagStyled(option);
    } else if (option.node?.is(ENode.Math)) {
      return new MathStyled(option);
    } else if (option.node?.is(ENode.Text)) {
      return new TextStyled(option);
    } else if (option.node?.is(ENode.LineBreak)) {
      return new LineBreakStyled(option);
    } else if (option.node?.is(ENode.Emoji)) {
      return new EmojiStyled(option);
    } else if (option.node?.is(ENode.Strong)) {
      return new StrongStyled(option);
    } else if (option.node?.is(ENode.Emphasis)) {
      return new EmphasisStyled(option);
    } else if (option.node?.is(ENode.StrikeThrough)) {
      return new StrikeThroughStyled(option);
    } else if (option.node?.is(ENode.Image)) {
      return new ImageStyled(option);
    } else if (option.node?.is(ENode.Link)) {
      return new LinkStyled(option);
    } else if (option.node?.is(ENode.FootnoteRef)) {
      return new FootnoteRefStyled(option);
    } else if (option.node?.is(ENode.FootnoteDef)) {
      return new FootnoteDefStyled(option);
    } else if (option.node?.is(ENode.Superscript) || option.node?.is(ENode.Subscript)) {
      return new SuxScriptStyled(option);
    } else if (option.node?.is(ENode.Inline)) {
      return new InlineStyled(option);
    } else if (option.node?.is(ENode.StyledContent)) {
      return new StyledContentStyled(option);
    }
    return undefined;
  }
}
class FragmentStyled extends Styled {
  get node() {
    return this.option.node as (Fragment | undefined);
  }
  protected building(option: IStyledBuild): void {
    if (!!option.engine.ctx?.fragmentEnable) {
      DocumentStyled.building(this, option);
    } else {
      this.node?.children?.forEach(node => {
        Styled.create({ node })?.build(option);
      });
    }
  }
}
class DocumentStyled extends Styled {
  get node() {
    return this.option.node as (Document | undefined);
  }
  building(option: IStyledBuild) {
    if (!!option.engine.ctx?.fragmentEnable) {
      this.node?.children?.forEach(node => {
        Styled.create({ node })?.build(option);
      });
    } else {
      DocumentStyled.building(this, option);
    }
  }
  static building(that: Styled, option: IStyledBuild) {
    const group = StyledObject.group({ styled: that }, [
      new StyledLetterSpacingValue(option.theme.document?.letterSpacing),
      new StyledBaselineOffsetValue(option.theme.document?.baselineOffset),
      new StyledLineHeightValue(option.theme.document?.lineHeight),
      new StyledTextValue(option.theme.document?.font),
    ]);
    option.didCreateStyled(group);

    for (const node of (that.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
}
class ParagraphStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    if (this.node?.hidden) {
      //  忽略本级paragraph，直接透传至父级处理
      for (const node of (this.node?.children ?? [])) {
        Styled.create({ node })?.build(option);
      }
    } else {
      const group = StyledObject.group({ styled: this });
      option.didCreateStyled(group);
      for (const node of (this.node?.children ?? [])) {
        Styled.create({ node })?.build({
          theme: option.theme,
          engine: option.engine,
          didCreateStyled: styled => {
            group.attach(styled);
          },
        });
      }
    }
  }
}
class ThematicBreakStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this });
    option.didCreateStyled(group);

    group.attach(new StyledObject(
      { styled: this },
      new StyledSpan({
        onMeasure: (_span, _measureInfo) => {
          const width: number = group.blockArea?.width?.value ?? 0;
          const height: number = MDLength.vp(option.theme.thematicBreak?.lineHeight?.height?.value ?? 0).value;
          return { width, height };
        },
        onDraw: (span, context, drawInfo) => {
          const metrics = span.metrics;
          const brush = new drawing.Brush();
          brush.setColor(MDColor.makeColorFromResourceColor(option.theme.thematicBreak?.lineColor ?? Color.Black));
          context.canvas.attachBrush(brush);
          context.canvas.drawRect({
            left: drawInfo.x,
            top: drawInfo.baseline - MDLength.vp2px(metrics.height ?? 0).value/2*0.9,
            right: MDLength.vp2px(metrics.width).value,
            bottom: drawInfo.baseline + MDLength.vp2px(metrics.height ?? 0).value/2*0.9,
          });
          context.canvas.detachBrush();
        },
      }),
    ));
  }
}
class HeadingStyled extends Styled {
  get node() {
    return this.option.node as (Heading | undefined);
  }
  building(option: IStyledBuild) {
    let level: HeadingLevelStyling | undefined = undefined;
    if (this.node?.level === 1) {
      level = option.theme.heading?.h1;
    } else if (this.node?.level === 2) {
      level = option.theme.heading?.h2;
    } else if (this.node?.level === 3) {
      level = option.theme.heading?.h3;
    } else if (this.node?.level === 4) {
      level = option.theme.heading?.h4;
    } else if (this.node?.level === 5) {
      level = option.theme.heading?.h5;
    } else if (this.node?.level === 6) {
      level = option.theme.heading?.h6;
    }
    const group = StyledObject.group({ styled: this }, [
      new StyledTextValue(level?.font),
      new StyledLineHeightValue(level?.lineHeight),
    ]);
    option.didCreateStyled(group);

    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
}
class QuoteStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this }, [
      new StyledTextValue(option.theme.quote?.font),
      new StyledParagraphValue(option.theme.quote?.contentParagraph),
    ]);
    option.didCreateStyled(group);

    let edgeOffset: number = 0;
    let lastOffset: number = 0;
    let lastLength: number = 0;
    group.attach(
      new StyledObject(
        { styled: this },
        new StyledSpan({
          onMeasure: (_span, _measureInfo) => {
            return { width: 0 };
          },
          onDraw: (_span, context, drawInfo) => {
            const rects = group.getRectsForRange(
              { start: edgeOffset, end: lastOffset + lastLength },
              OhosGText.RectWidthStyle.TIGHT, OhosGText.RectHeightStyle.TIGHT,
            );
            if (rects && rects.length > 0) {
              const bottom = rects[rects.length - 1].rect.bottom;
              const brush = new drawing.Brush();
              brush.setColor(MDColor.makeColorFromResourceColor(option.theme.quote?.edgeColor ?? Color.Gray));
              context.canvas.attachBrush(brush);
              const left: number = drawInfo.x - MDLength.vp2px((option.theme.quote?.contentParagraph?.leadingMargin as LengthMetrics)?.value ?? 0).value;
              const right: number = left + MDLength.vp2px(option.theme.quote?.edgeWidth?.value ?? 0).value;
              context.canvas.drawRect({
                left, right,
                top: drawInfo.lineTop, bottom: bottom,
              })
              context.canvas.detachBrush();
            }
          },
        }),
      ).on<IStyledObjectAttachEvent>(EStyledObjectEvent.DidAttachTo, event => {
        edgeOffset = event.current.offset;
      })
    );

    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
          // lastOffset = styled.offset;
          // lastLength = styled.length;
        },
        didBuild: anchor => {
          lastOffset = anchor.offset;
          lastLength = anchor.length;
        },
      });
    }
  }
}
class CodeStyled extends Styled {
  get node() {
    return this.option.node as (Code | undefined);
  }
  building(option: IStyledBuild) {
    const code = this.node;
    if (code) {
      if (code.layout === ELayout.Inline) {
        CodeStyled.buildingInline(this, option, code.content);
      } else {
        this.buildingBlock(code, option);
      }
    }
  }
  buildingBlock(code: Code, option: IStyledBuild) {
    if (code.styledContent) {
      // option.didCreateStyled(code.styled as StyledObject);
      const group = StyledObject.group({ styled: this });
      option.didCreateStyled(group);
      group.attach(new StyledEmbed(
        { styled: this },
        {
          initMetrics: { width: group.blockArea?.width?.value ?? 0 },
          builderType: EStyledEmbedBuilder.Code,
          embedController: new StyledEmbedController(),
          theme: option.theme,
        },
      ));
    }
  }
  static buildingInline(that: Styled, option: IStyledBuild, content?: string | Node) {
    if (content) {
      const group = StyledObject.group({ styled: that });
      option.didCreateStyled(group);
      group.attach(new StyledObject({ styled: that }, ' ', [
        new StyledBackgroundColorValue({
          color: option.theme.inlineCode?.background?.color,
          radiuses: {
            topLeft: option.theme.inlineCode?.background?.radius,
            bottomLeft: option.theme.inlineCode?.background?.radius,
          },
        }),
      ]));
      if (typeof content === 'string') {
        group.attach(new StyledObject({ styled: that }, content, [
          new StyledBackgroundColorValue({
            color: option.theme.inlineCode?.background?.color,
          }),
        ]));
      } else {
        const contentGroup = StyledObject.group({ styled: that }, [
          new StyledBackgroundColorValue({
            color: option.theme.inlineCode?.background?.color,
          }),
        ]);
        group.attach(contentGroup);
        for (const node of (content.children ?? [])) {
          Styled.create({ node })?.build({
            theme: option.theme,
            engine: option.engine,
            didCreateStyled: styled => {
              contentGroup.attach(styled);
            },
          });
        }
      }
      group.attach(new StyledObject({ styled: that }, ' ', [
        new StyledBackgroundColorValue({
          color: option.theme.inlineCode?.background?.color,
          radiuses: {
            topRight: option.theme.inlineCode?.background?.radius,
            bottomRight: option.theme.inlineCode?.background?.radius,
          },
        }),
      ]));
    }
  }
}
class TableStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this });
    option.didCreateStyled(group);
    group.attach(new StyledEmbed(
      { styled: this },
      {
        initMetrics: { width: group.blockArea?.width?.value ?? 0 },
        builderType: EStyledEmbedBuilder.Table,
        embedController: new StyledEmbedController(),
        theme: option.theme,
      },
    ));
    // group.attach(StyledObject.break({ styled: this }));
  }
}
class TableItemStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this });
    option.didCreateStyled(group);
    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
}
class ListStyled extends Styled {
  get node() {
    return this.option.node as (List | undefined);
  }
  building(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this }, [
      new StyledParagraphValue(
        this.node?.isTop ? option.theme.listItem?.contentTopParagraph : option.theme.listItem?.contentParagraph
      ),
    ]);
    option.didCreateStyled(group);

    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
}
class ListItemStyled extends Styled {
  get node() {
    return this.option.node as (ListItem | undefined);
  }
  get content() {
    const first = this.node?.first?.deref();
    return first?.is(ENode.Paragraph) ? first : undefined;
  }
  get list() {
    const last = this.node?.last?.deref();
    return last?.is(ENode.List) ? last : undefined;
  }
  get isTop() {
    return !!(this.node?.parentList?.isTop);
  }
  get inQuote() {
    let isIn: boolean = false;
    let parent = this.node?.parent?.deref();
    while (parent) {
      if (parent.is(ENode.Quote)) {
        isIn = true;
        break;
      }
      parent = parent.parent?.deref();
    }
    return isIn;
  }
  building(option: IStyledBuild) {
    const item = StyledObject.group({ styled: this });
    option.didCreateStyled(item);

    const inQuote = this.inQuote;

    do {
      //  FIXME: why the first item in quote can NOT FOLLOW PARAGRAPH LEADING MARGIN?
      const leading = (option.theme.listItem?.contentTopParagraph?.leadingMargin as LengthMetrics)?.value ?? 0;
      if (inQuote && this.isTop && !this.node?.prev?.deref() && leading) {
        item.attach(new StyledObject({ styled: this }, new StyledSpan({
          onMeasure: (_span, _measureInfo) => {
            return { width: leading };
          },
        })));
      }
    } while (0);

    const obj = new StyledObject({ styled: this }, new StyledSpan({
      onMeasure: (_span, _measureInfo) => {
        return { width: 0 };
      },
      onDraw: (_span, context, drawInfo) => {
        const textStyle = obj.cascadedStyle<TextStyle>(StyledStringKey.FONT);

        if (this.node?.itemType === EListItem.CheckBox) {
          const width = MDLength.vp2px(option.theme.listItem?.taskFlagWidth?.value ?? 0).value;
          const left = drawInfo.x - width;
          const top = drawInfo.baseline - width;
          const inset = (rect: Rect): Rect => {
            const v = MDLength.vp2px(1).value;
            return {
              left: rect.left + v,
              top: rect.top + v,
              right: rect.right - v,
              bottom: rect.bottom - v,
            };
          };
          let rect: Rect = {
            left, top,
            right: left + width,
            bottom: top + width,
          };
          const color = inQuote ? textStyle?.fontColor : option.theme.listItem?.taskFlagColor;
          do {
            const brush = new drawing.Brush();
            brush.setColor(MDColor.makeColorFromResourceColor(color ?? Color.Black));
            context.canvas.attachBrush(brush);
            context.canvas.drawRect(rect);
            context.canvas.detachBrush();
          } while (0);
          do {
            rect = inset(rect);
            const brush = new drawing.Brush();
            brush.setColor(MDColor.makeColorFromResourceColor(Color.White));
            context.canvas.attachBrush(brush);
            context.canvas.drawRect(rect);
            context.canvas.detachBrush();
          } while (0);
          if (this.node?.checked) {
            rect = inset(rect);
            const brush = new drawing.Brush();
            brush.setColor(MDColor.makeColorFromResourceColor(color ?? Color.Black));
            context.canvas.attachBrush(brush);
            context.canvas.drawRect(rect);
            context.canvas.detachBrush();
          }
        } else {
          const isTop = this.isTop && !inQuote;
          const leading = isTop ? option.theme.listItem?.contentTopParagraph : option.theme.listItem?.contentParagraph;

          const width = MDLength.vp2px((leading?.leadingMargin as LengthMetrics)?.value ?? 0).value;
          if (width <= 0) {
            return;
          }
          const x: number = drawInfo.x - width;

          const topBoxWidth = MDLength.vp2px(option.theme.listItem?.contentTopBoxWidth?.value ?? 0).value;
          const topBoxTop = drawInfo.baseline - topBoxWidth * 8 / 9;
          const topBoxRect: Rect = {
            left: x, right: x + topBoxWidth, top: topBoxTop, bottom: topBoxTop + topBoxWidth,
          };
          if (this.node?.itemType === EListItem.Ordered) {
            const label = this.node?.info || '';
            if (isTop) {
              do {
                const boxRadius = MDLength.vp2px(option.theme.listItem?.contentTopBoxRadius?.value ?? 0).value;
                const brush = new drawing.Brush();
                brush.setColor(MDColor.makeColorFromResourceColor(option.theme.listItem?.contentTopBoxBackgroundColor ?? Color.White));
                context.canvas.attachBrush(brush);
                context.canvas.drawRoundRect(new drawing.RoundRect(topBoxRect, boxRadius, boxRadius));
                context.canvas.detachBrush();
              } while (0);
              do {
                const textSize = option.engine.ctx?.measureTextSize({
                  textContent: label,
                  textStyle: new StyledTextValue(option.theme.listItem?.contentTopBoxFont).value,
                });
                const textX = topBoxRect.left + (topBoxRect.right - topBoxRect.left - (textSize?.width as number ?? 0)) / 2;
                const textY = drawInfo.baseline - (option.theme.listItem?.contentTopBoxFont?.fontSize?.value ?? 0) * 2 / 5;
                const font = new drawing.Font();
                font.setSize(MDLength.vp2px(option.theme.listItem?.contentTopBoxFont?.fontSize?.value ?? 0).value);
                const pen = new drawing.Pen();
                pen.setStrokeWidth(1);
                pen.setColor(MDColor.makeColorFromResourceColor(option.theme.listItem?.contentTopBoxFont?.fontColor ?? Color.Black));
                context.canvas.attachPen(pen);
                const brush = new drawing.Brush();
                brush.setColor(MDColor.makeColorFromResourceColor(option.theme.listItem?.contentTopBoxFont?.fontColor ?? Color.Black));
                context.canvas.attachBrush(brush);
                const blob = drawing.TextBlob.makeFromString(label, font);
                context.canvas.drawTextBlob(blob, textX, textY);
                context.canvas.detachBrush();
                context.canvas.detachPen();
              } while (0);
            } else {
              const font = new drawing.Font();
              font.setSize(MDLength.vp2px(textStyle?.fontSize as number ?? 0).value);
              const pen = new drawing.Pen();
              pen.setStrokeWidth(1);
              pen.setColor(MDColor.makeColorFromResourceColor(textStyle?.fontColor ?? Color.Black));
              context.canvas.attachPen(pen);
              const brush = new drawing.Brush();
              brush.setColor(MDColor.makeColorFromResourceColor(textStyle?.fontColor ?? Color.Black));
              context.canvas.attachBrush(brush);
              const blob = drawing.TextBlob.makeFromString(`${label}.`, font);
              context.canvas.drawTextBlob(blob, x, drawInfo.baseline);
              context.canvas.detachBrush();
              context.canvas.detachPen();
            }
          } else if (this.node?.itemType === EListItem.Bullet) {
            if (isTop) {
              const badgeWidth = MDLength.vp2px(option.theme.listItem?.contentTopBadgeWidth?.value ?? 0).value ?? 0;
              const brush = new drawing.Brush();
              brush.setColor(MDColor.makeColorFromResourceColor(option.theme.listItem?.contentTopBadgeBackgroundColor ?? Color.Black));
              context.canvas.attachBrush(brush);
              context.canvas.drawCircle(
                topBoxRect.left + (topBoxRect.right - topBoxRect.left)/2,
                topBoxRect.top + (topBoxRect.bottom - topBoxRect.top)/2,
                badgeWidth / 2,
              );
              context.canvas.detachBrush();
            } else {
              const color = inQuote ? textStyle?.fontColor : option.theme.listItem?.contentBadgeBackgroundColor;
              const leading = MDLength.vp2px((option.theme.listItem?.contentParagraph?.leadingMargin as LengthMetrics)?.value ?? 0).value;
              const badgeWidth = MDLength.vp2px(option.theme.listItem?.contentBadgeWidth?.value ?? 0).value ?? 0;
              const brush = new drawing.Brush();
              brush.setColor(MDColor.makeColorFromResourceColor(color ?? Color.Black));
              context.canvas.attachBrush(brush);
              context.canvas.drawCircle(
                drawInfo.x - leading + badgeWidth,
                drawInfo.baseline - badgeWidth,
                badgeWidth / 2,
              );
              context.canvas.detachBrush();
            }
          }
        }
      }
    }));
    item.attach(obj);

    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          item.attach(styled);
        },
      });
    }
  }
}
class HtmlTagStyled extends Styled {
  get node() {
    return this.option.node as (HtmlTag | undefined);
  }
  building(option: IStyledBuild) {
    if (this.node?.tagName === 'sup') {
      this.buildingSux(option, false);
    } else if (this.node?.tagName === 'sub') {
      this.buildingSux(option, true);
    } else if (this.node?.tagName === 'u') {
      this.buildingU(option);
    } else if (this.node?.tagName === 'br') {
      this.buildingBr(option);
    } else if (this.node?.tagName === 's') {
      this.buildingS(option);
    } else if (this.node?.tagName === 'del') {
      this.buildingDel(option);
    } else if (this.node?.tagName === 'mark') {
      this.buildingMark(option);
    } else if (this.node?.tagName === 'span') {
      this.buildingSpan(option);
    } else if (this.node?.tagName === 'cite') {
      this.buildingCite(option);
    } else if (this.node?.tagName === 'font') {
      this.buildingFont(option);
    } else if (this.node?.tagName === 'img') {
      this.buildingImg(option);
    } else if (this.node?.tagName === 'a') {
      this.buildingA(option);
    } else if (this.node?.tagName === 'icon') {
      this.buildingIcon(option);
    }
  }
  private buildingIcon(option: IStyledBuild) {
    const src = this.node?.attributes?.find(ele => ele.name === 'src')?.value;
    if (src && typeof src === 'string') {
      const group = StyledObject.group({ styled: this });
      option.didCreateStyled(group);

      const request: IImageServiceRequest = { url: src };
      const imageObject = new StyledObject(
        { styled: this },
        new StyledImageSpan({
          buildOption: option,
          request,
          onImageSourceRequested: () => {
            imageObject.root?.deref()?.emit<IStyledObjectReplaceStyleEvent>(EStyledObjectEvent.DidReplaceStyle, {});
          },
          onMeasure: (span: StyledImageSpan, _measureInfo) => {
            const imageSource = span.imageSource;
            if (!imageSource) {
              return { width: 0 };
            }
            const textStyle = imageObject.cascadedStyle<TextStyle>(StyledStringKey.FONT);
            const fontSize = textStyle?.fontSize ?? option.theme.document?.font?.fontSize?.value ?? 0;
            const imgHeight: number = MDLength.vp2px(fontSize).value;
            const imageInfo = imageSource.getImageInfoSync();
            const imgWidth: number = imageInfo.size.width * imgHeight / (imageInfo.size.height ?? 1);
            return { width: MDLength.px2vp(imgWidth).value, height: MDLength.px2vp(imgHeight).value };
          },
          onDraw: (span: StyledImageSpan, context, drawInfo) => {
            const imageSource = span.imageSource;
            if (imageSource) {
              const canvas = context.canvas;
              const pixelMap = imageSource.createPixelMapSync();
              const top = drawInfo.baseline - MDLength.vp2px(span.metrics.height ?? 0).value * 8 / 9;
              canvas.drawImageRect(pixelMap, {
                left: drawInfo.x,
                top,
                right: drawInfo.x + MDLength.vp2px(span.metrics.width).value,
                bottom: top + MDLength.vp2px(span.metrics.height ?? 0).value,
              });
              pixelMap.release();
            }
          },
        }),
      );
      group.attach(imageObject);
    }
  }
  private buildingA(option: IStyledBuild) {
    const href = this.node?.attributes?.find(ele => ele.name === 'href')?.value;
    LinkStyled.building(this, option, typeof href === 'string' ? href : undefined);
  }
  private buildingImg(option: IStyledBuild) {
    const src = this.node?.attributes?.find(ele => ele.name === 'src')?.value;
    const alt = this.node?.attributes?.find(ele => ele.name === 'alt')?.value;
    if (src && typeof src === 'string') {
      ImageStyled.building(this, option, src, typeof alt === 'string' ? alt : undefined);
    }
  }
  private buildingFont(option: IStyledBuild) {
    //  color like: #fff | red | rgb(255, 0, 0) | rgba(255, 0, 0, 0.5)
    const color = this.node?.attributes?.find(ele => ele.name === 'color')?.value;
    const group = StyledObject.group({ styled: this }, [new StyledTextValue({
      fontColor: (typeof color === 'string') ? color : undefined,
    })]);
    option.didCreateStyled(group);
    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
  private buildingCite(option: IStyledBuild) {
    EmphasisStyled.building(this, option);
  }
  private buildingSpan(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this });
    option.didCreateStyled(group);
    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
  private buildingMark(option: IStyledBuild) {
    CodeStyled.buildingInline(this, option, this.node);
  }
  private buildingDel(option: IStyledBuild) {
    StrikeThroughStyled.building(this, option);
  }
  private buildingS(option: IStyledBuild) {
    StrikeThroughStyled.building(this, option);
  }
  private buildingBr(option: IStyledBuild) {
    LineBreakStyled.building(this, option);
  }
  private buildingSux(option: IStyledBuild, isSubscript: boolean) {
    if (this.node) {
      const content = this.node.first?.deref();
      if (content && content.is(ENode.Text)) {
        SuxScriptStyled.building(this, isSubscript, option, content.content);
      }
    }
  }
  private buildingU(option: IStyledBuild) {
    if (this.node) {
      let u_offset: number = 0;
      let end_offset: number = 0;
      let end_length: number = 0;
      const u = new StyledObject({ styled: this }, new StyledSpan({
        onMeasure: (_span, _measureInfo) => {
          return { width: 0 };
        },
        onDraw: (_span, context, _drawInfo) => {
          const rects = u.getRectsForRange(
            { start: u_offset, end: end_offset + end_length },
            OhosGText.RectWidthStyle.TIGHT, OhosGText.RectHeightStyle.TIGHT,
          );
          if (rects) {
            const brush = new drawing.Brush();
            brush.setColor(MDColor.makeColorFromResourceColor(option.theme.underline?.markColor ?? Color.Black));
            context.canvas.attachBrush(brush);
            rects.forEach(ele => {
              context.canvas.drawRect({
                left: ele.rect.left,
                right: ele.rect.right,
                top: ele.rect.bottom - MDLength.vp2px(option.theme.underline?.markHeight?.value ?? 0).value,
                bottom: ele.rect.bottom,
              });
            });
            context.canvas.detachBrush();
          }
        },
      }));
      option.didCreateStyled(u);
      u_offset = u.offset;

      for (const node of (this.node?.children ?? [])) {
        Styled.create({ node })?.build({
          theme: option.theme,
          engine: option.engine,
          didCreateStyled: styled => {
            u.attach(styled);
          },
          didBuild: anchor => {
            end_offset = anchor.offset;
            end_length = anchor.length;
          },
        });
      }
    }
  }
}
class MathStyled extends Styled {
  get node() {
    return this.option.node as (MathNode | undefined);
  }
  building(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this });
    option.didCreateStyled(group);

    const anchor = StyledObject.empty();
    group.attach(anchor);
    const font = anchor.cascadedStyle<TextStyle>(StyledStringKey.FONT);

    const mathObject = new StyledObject(
      { styled: this },
      new StyledMathSpan({
        buildOption: option,
        request: {
          content:  this.node?.content || '',
          hash: this.node?.mathHash,
          fontSize: font?.fontSize,
          fontColor: font?.fontColor ? MDColor.toHex(font?.fontColor) : undefined,
        },
        onResourceLoaded: (_span) => {
          mathObject.root?.deref()?.emit<IStyledObjectReplaceStyleEvent>(EStyledObjectEvent.DidReplaceStyle, {});
        },
        onMeasure: (span, _measureInfo) => {
          if (span.imageSource) {
            const imageInfo = span.imageSource.getImageInfoSync();
            return {
              width: MDLength.px2vp(imageInfo.size.width).value,
              height: MDLength.px2vp(imageInfo.size.height).value,
            };
          }
          return { width: 0 };
        },
        onDraw: (span, context, drawInfo) => {
          if (span.imageSource) {
            const imageInfo = span.imageSource.getImageInfoSync();
            const pixelMap = span.imageSource.createPixelMapSync();
            context.canvas.drawImageRect(pixelMap, {
              left: drawInfo.x,
              top: drawInfo.baseline - imageInfo.size.height * 8 / 9,
              right: drawInfo.x + imageInfo.size.width,
              bottom: drawInfo.baseline,
            });
            pixelMap.release();
          }
        },
      }),
    );

    group.attach(mathObject);
  }
}
class TextStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    option.didCreateStyled(new StyledObject({ styled: this }, this.node?.content ?? ''));
  }
}
class LineBreakStyled extends Styled {
  get node() {
    return this.option.node as (LineBreak | undefined);
  }
  building(option: IStyledBuild) {
    LineBreakStyled.building(this, option);
  }
  static building(that: Styled, option: IStyledBuild) {
    option.didCreateStyled(StyledObject.break({ styled: that }));
  }
}
class EmojiStyled extends Styled {
  get node() {
    return this.option.node as (Emoji | undefined);
  }
  building(option: IStyledBuild) {
    option.didCreateStyled(new StyledObject(
      { styled: this },
      this.node?.content ?? ''
    ));
  }
}
class StrongStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this }, [
      new StyledTextValue(option.theme.strong?.font),
    ]);
    option.didCreateStyled(group);

    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
}
class EmphasisStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    EmphasisStyled.building(this, option);
  }
  static building(that: Styled, option: IStyledBuild) {
    const group = StyledObject.group({ styled: that }, [
      new StyledTextValue(option.theme.emphasis?.font),
    ]);
    option.didCreateStyled(group);

    for (const node of (that.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
}
class StrikeThroughStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    StrikeThroughStyled.building(this, option);
  }
  static building(that: Styled, option: IStyledBuild) {
    const group = StyledObject.group({ styled: that }, [
      new StyledDecorationValue(option.theme.strikeThrough?.decoration),
    ]);
    option.didCreateStyled(group);

    for (const node of (that.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
}
class ImageStyled extends Styled {
  get node() {
    return this.option.node as (Image | undefined);
  }
  building(option: IStyledBuild) {
    if (!this.node?.src) {
      log.w(`image build failed. src is empty. nodeId: ${this.node?.id}`);
      return;
    }
    ImageStyled.building(this, option, this.node?.src, this.node?.alt);
  }
  static building(that: Styled, option: IStyledBuild, src: string, _alt?: string) {
    const group = StyledObject.group({ styled: that });
    option.didCreateStyled(group);

    const request: IImageServiceRequest = { url: src };
    const imageObject = new StyledObject(
      { styled: that },
      new StyledImageSpan({
        buildOption: option,
        request,
        onImageSourceRequested: () => {
          imageObject.root?.deref()?.emit<IStyledObjectReplaceStyleEvent>(EStyledObjectEvent.DidReplaceStyle, {});
        },
        onMeasure: (span: StyledImageSpan, _measureInfo) => {
          const imageSource = span.imageSource;
          if (!imageSource) {
            return { width: 0 };
          }
          const maxWidth = MDLength.vp2px(group.blockArea?.width?.value ?? 0).value;
          const maxHeight = MDLength.vp2px(option.theme.image?.maxHeight?.value ?? 0).value;
          const imageInfo = imageSource.getImageInfoSync();
          let width = Math.min(maxWidth, imageInfo.size.width);
          let height = imageInfo.size.height * width / (imageInfo.size.width ?? 1);
          if (height > maxHeight) {
            width = maxHeight * width / (height ?? 1);
            height = maxHeight;
          }
          return { width: MDLength.px2vp(width).value, height: MDLength.px2vp(height).value };
        },
        onDraw: (span: StyledImageSpan, context, drawInfo) => {
          const imageSource = span.imageSource;
          if (imageSource) {
            const canvas = context.canvas;
            const pixelMap = imageSource.createPixelMapSync();
            canvas.drawImageRect(pixelMap, {
              left: drawInfo.x,
              top: drawInfo.lineTop,
              right: drawInfo.x + MDLength.vp2px(span.metrics.width).value,
              bottom: drawInfo.lineTop + MDLength.vp2px(span.metrics.height ?? 0).value,
            });
            pixelMap.release();
          }
        },
      }),
    );
    group.attach(imageObject);
  }
}
class LinkStyled extends Styled {
  get node() {
    return this.option.node as (Link | undefined);
  }
  building(option: IStyledBuild) {
    if (this.node && this.node.is(ENode.Link)) {
      LinkStyled.building(this, option, this.node?.href);
    }
  }
  static building(that: Styled, option: IStyledBuild, _href?: string) {
    if (that.node) {
      const group = StyledObject.group({ styled: that }, [
        new StyledTextValue(option.theme.link?.font),
        new StyledGestureValue({
          onClick: event => {
            option.engine.event?.invokeClickGesture(that.node!, event);
          },
        }),
      ]);
      option.didCreateStyled(group);

      for (const node of (that.node?.children ?? [])) {
        Styled.create({ node })?.build({
          theme: option.theme,
          engine: option.engine,
          didCreateStyled: styled => {
            group.attach(styled);
          },
        });
      }

      const icon = new StyledObject({ styled: that }, new StyledSpan({
        onMeasure: (_span, _measureInfo) => {
          return {
            width: option.theme.link?.iconSize?.width?.value ?? 0,
            height: option.theme.link?.iconSize?.height?.value,
          };
        },
        onDraw: (span, context, drawInfo) => {
          const canvas = context.canvas;
          const image = option.engine.image?.load('icon_link.png');
          if (image) {
            const top = drawInfo.baseline - MDLength.vp2px(span.metrics.height ?? 0).value;
            const imageRect: Rect = {
              top,
              left: drawInfo.x,
              right: drawInfo.x + MDLength.vp2px(span.metrics.width).value,
              bottom: top + MDLength.vp2px(span.metrics.height ?? 0).value,
            };
            const imagePixel = image.createPixelMapSync();
            canvas.save();
            canvas.drawImageRect(imagePixel, imageRect);
            canvas.restore();
            imagePixel.release();
            image.release();
          }
        },
      }));
      group.attach(icon);
    }
  }
}
class FootnoteRefStyled extends Styled {
  get node() {
    return this.option.node as (FootnoteRef | undefined);
  }
  building(option: IStyledBuild) {
    FootnoteRefStyled.building(this, this.node?.label ?? '', option, this.node);
  }
  static building(styled: IStyled, text: string, option: IStyledBuild, node?: Node) {
    const obj = new StyledObject(
      { styled },
      new StyledSpan({
        onMeasure: (_span, _measureInfo) => {
          const width: number = option.theme.footnoteRef?.minSize?.width?.value ?? 0;
          const height: number = option.theme.footnoteRef?.minSize?.height?.value ?? 0;
          return { width, height };
        },
        onDraw: (_span, context, drawInfo) => {
          const canvas = context.canvas;

          const textValue = obj.cascadedStyle<TextStyle>(StyledStringKey.FONT);
          const fontSize = textValue?.fontSize ?? 0;

          //  bg badge
          do {
            const offset = MDLength.vp2px(MDLength.baselineOffsetVP(fontSize).value);

            const brush = new drawing.Brush();
            brush.setColor(MDColor.makeColorFromResourceColor(option.theme.footnoteRef?.background?.color ?? Color.Black));
            canvas.attachBrush(brush);
            const radius = MDLength.vp2px(option.theme.footnoteRef?.minSize?.width?.value ?? 0).value/2;
            const x = drawInfo.x + radius;
            const y = drawInfo.baseline + offset.value - radius;
            canvas.drawCircle(x, y, radius);
            canvas.detachBrush();
          } while (0);
          //  text content
          do {
            if (text.length === 0) {
              break;
            }
            const offset = MDLength.vp2px(MDLength.baselineOffsetVP(fontSize, 1/9).value);

            const textStyle = obj.cascadedStyle<TextStyle>(StyledStringKey.FONT);
            const size = option.engine.ctx?.measureTextSize({
              textContent: text,
              textStyle,
            });
            const x = drawInfo.x + (MDLength.vp2px(option.theme.footnoteRef?.minSize?.width?.value ?? 0).value - (size?.width as number ?? 0))/2;
            const font = new drawing.Font();
            font.setSize(MDLength.vp2px(textStyle?.fontSize ?? 0).value);
            const brush = new drawing.Brush();
            brush.setColor(MDColor.makeColorFromResourceColor(textStyle?.fontColor ?? Color.Black));
            const blob = drawing.TextBlob.makeFromString(text, font);
            canvas.attachBrush(brush);
            canvas.drawTextBlob(blob, x, drawInfo.baseline - offset.value);
            canvas.detachBrush();
          } while (0);
        },
      }),
      [
        new StyledTextValue(option.theme.footnoteRef?.font),
        new StyledGestureValue({
          onClick: event => {
            if (node) {
              option.engine.event?.invokeClickGesture(node, event);
            }
          },
        }),
      ]
    );
    option.didCreateStyled(obj);
  }
}
class FootnoteDefStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {

  }
}
class SuxScriptStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  get content() {
    const node = this.node;
    if (node) {
      const first = node.first?.deref();
      if (first && first.is(ENode.Text)) {
        return first.content;
      }
    }
    return undefined;
  }
  get isSubscript() {
    return !!(this.node?.is(ENode.Subscript));
  }
  building(option: IStyledBuild) {
    SuxScriptStyled.building(this, this.isSubscript, option, this.content);
  }
  static building(
    that: IStyled, isSubscript: boolean,
    option: IStyledBuild, content?: string
  ) {
    //  FIXME: span的letterSpacing需要修复
    let contentSize: SizeOptions = {};
    const obj = new StyledObject(
      { styled: that },
      new StyledSpan({
        onMeasure: (_span, _measureInfo) => {
          if (content) {
            contentSize = option.engine.ctx?.measureTextSize({
              textContent: content,
              textStyle: obj.cascadedStyle<TextStyle>(StyledStringKey.FONT),
            }) ?? {};
            return { width: MDLength.px2vp((contentSize.width as number ?? 0)).value };
          }
          return { width: 0 };
        },
        onDraw: (_span, context, drawInfo) => {
          if (content) {
            const textStyle = obj.cascadedStyle<TextStyle>(StyledStringKey.FONT);
            do {
              const font = new drawing.Font();
              font.setSize(MDLength.vp2px(textStyle?.fontSize ?? 0).value);
              const brush = new drawing.Brush();
              brush.setColor(MDColor.makeColorFromResourceColor(textStyle?.fontColor ?? Color.Black));
              const blob = drawing.TextBlob.makeFromString(content, font);
              const y = isSubscript ?
                drawInfo.baseline + (contentSize.height as number ?? 0)/2*0.9 :
                drawInfo.baseline - (contentSize.height as number ?? 0)/2*0.9
              context.canvas.attachBrush(brush);
              context.canvas.drawTextBlob(blob, drawInfo.x, y);
              context.canvas.detachBrush();
            } while (0);
          }
        },
      }),
      [
        new StyledTextValue(isSubscript ?
          option.theme.subscript?.font :
          option.theme.superscript?.font),
      ]
    );
    option.didCreateStyled(obj);
  }
}
class StyledContentStyled extends Styled {
  get node() {
    return this.option.node as (StyledContent | undefined);
  }
  building(option: IStyledBuild) {
    if (this.node && this.node.styled) {
      option.didCreateStyled(this.node.styled as StyledObject);
    }
  }
}
class InlineStyled extends Styled {
  get node() {
    return this.option.node as (Node | undefined);
  }
  building(option: IStyledBuild) {
    const group = StyledObject.group({ styled: this });
    option.didCreateStyled(group);
    for (const node of (this.node?.children ?? [])) {
      Styled.create({ node })?.build({
        theme: option.theme,
        engine: option.engine,
        didCreateStyled: styled => {
          group.attach(styled);
        },
      });
    }
  }
}